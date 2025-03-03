import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN'];

  test('client.close() disposes all async resources', skip: testToken != null ? false : 'No test token provided', () async {
    final receivePort = ReceivePort();

    Future<void> createAndDisposeClient(SendPort sendPort) async {
      // Re-declare so we don't attempt to copy the outer context to the isolate.
      final testToken = Platform.environment['TEST_TOKEN'];
      final testGuild = Platform.environment['TEST_GUILD'];

      final client = await Nyxx.connectGatewayWithOptions(GatewayApiOptions(
        token: testToken!,
        intents: GatewayIntents.allUnprivileged,
        totalShards: 10, // Use many shards to ensure the client is still connecting some shards when we close it.
      ));

      final user = await client.user.get();

      await client.onReady.first;

      // Queue many shard messages to ensure the rate limiter schedules them at a later time.
      for (int i = 0; i < 200; i++) {
        client.gateway.updatePresence(PresenceBuilder(status: CurrentUserStatus.online, isAfk: false));
      }

      // Get a handle to all async resources exposed on the client.

      // Also handles all the onXXX streams, as they are derived from onEvent.
      final clientEvents = client.onEvent.listen((_) {});
      final gatewayMessages = client.gateway.messages.listen((_) {});
      final gatewayEvents = client.gateway.events.listen((_) {});
      final membersStream = (testGuild == null ? Stream.empty() : client.gateway.listGuildMembers(Snowflake.parse(testGuild))).listen((_) {});
      final shards = [
        for (final shard in client.gateway.shards) shard.listen((_) {}),
      ];
      final shardReceiveStreams = [
        for (final shard in client.gateway.shards) shard.receiveStream.listen((_) {}),
      ];
      final requests = client.httpHandler.onRequest.listen((_) {});
      final responses = client.httpHandler.onResponse.listen((_) {});
      final rateLimits = client.httpHandler.onRateLimit.listen((_) {});
      final assetStream = user.avatar.fetchStreamed().listen((_) {});

      // This single request should be representative of all methods on managers that
      // create a request from a known route, execute it using httpHandler.executeSafe,
      // and then parse the result (the vast majority of all manager methods).
      final userRequest = client.user.fetch();
      final assetRequest = user.avatar.fetch();
      final shardsDone = [
        for (final shard in client.gateway.shards) shard.done,
      ];
      final rateLimitedRequest = Future.wait([
        // GET /gateway/bot seems to have high rate limits. 10 requests should be enough to trigger it.
        for (int i = 0; i < 10; i++) client.gateway.fetchGatewayBot(),
      ]);

      sendPort.send('closing');

      // Create the future before calling close so that any error handlers are installed before
      // the close happens, in order to avoid any uncaught errors.
      final disposedFuture = Future.wait([
        // Streams
        clientEvents.asFuture(),
        gatewayMessages.asFuture(),
        gatewayEvents.asFuture(),
        membersStream.asFuture(),
        ...shards.map((s) => s.asFuture()),
        ...shardReceiveStreams.map((s) => s.asFuture()),
        requests.asFuture(),
        responses.asFuture(),
        rateLimits.asFuture(),
        assetStream.asFuture(),

        // Futures
        userRequest,
        assetRequest,
        ...shardsDone,
        rateLimitedRequest,
      ]);

      await client.close();

      sendPort.send('closed');

      // Expect all the async operations to finish in some way or another.
      try {
        await disposedFuture;
      } catch (e) {
        // Erroring is an accepted way of dealing with `client.close()` being called during an async operation.
      }

      sendPort.send('done');
    }

    final isolate = await Isolate.spawn(createAndDisposeClient, receivePort.sendPort, paused: true);
    isolate.addOnExitListener(receivePort.sendPort, response: 'exited');
    isolate.resume(isolate.pauseCapability!);

    var isDone = false;
    Timer? failTimer;

    final subscription = receivePort.listen((message) {
      if (message == 'closing') {
        failTimer = Timer(Duration(seconds: 1), () {
          receivePort.close();

          // Plugins can intercept calls to close(), but we should try to make calls to close() without any plugins as
          // fast as possible.
          // There is some networking involved (closing the WS connection has to send a close frame), so we allow this
          // to take _some_ time. Just not too much.
          fail('Client took more than a second to close');
        });
      } else if (message == 'closed') {
        failTimer!.cancel();
        failTimer = Timer(Duration(milliseconds: 250), () {
          receivePort.close();

          fail('Pending async operations did not complete in 250ms');
        });
      } else if (message == 'done') {
        isDone = true;

        failTimer!.cancel();
        failTimer = Timer(Duration(milliseconds: 500), () {
          receivePort.close();

          // If any async operations are still pending in the isolate (which they shouldn't), they will keep it alive.
          // Therefore we expect the isolate to exit immediately after client.close() completes, since that should be
          // the last async operation performed.
          // We allow up to 500ms of "wiggle room" to account for cross-isolate communication and isolate shutdown time.
          // This delay may not be enough to prevent this test from failing on very slow devices, or if the OS schedules
          // the threads execution in an unfortunate order. If this test is failing, be absolutely sure it's not failing
          // for some other reason before increasing this delay.
          fail('Isolate did not shut down in 500ms');
        });
      } else {
        assert(message == 'exited');

        failTimer!.cancel();

        // Completes the test.
        receivePort.close();

        // If isDone is false, then we didn't properly dispose of all async resources and left some "hanging", so
        // awaiting them caused the isolate to exit prematurely.
        // This also fails the test if the isolate exits because of an error.
        expect(isDone, isTrue, reason: 'isolate entrypoint should run to completion');
      }
    });

    await subscription.asFuture();
  });
}
