import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart' hide completes;

import '../function_completes.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN'];
  final testGuild = Platform.environment['TEST_GUILD'];

  group('Nyxx.connectGateway', skip: testToken != null ? false : 'No test token provided', () {
    Future<void> testClient(GatewayApiOptions options) async {
      late NyxxGateway client;

      await expectLater(() async => client = await Nyxx.connectGatewayWithOptions(options), completes);
      expect(client.gateway.messages, neverEmits(isA<ErrorReceived>()));
      await expectLater(client.onEvent, emits(isA<ReadyEvent>()));
      await expectLater(client.close(), completes);
    }

    for (final compression in GatewayCompression.values) {
      for (final payloadFormat in GatewayPayloadFormat.values) {
        if (payloadFormat != GatewayPayloadFormat.json && compression == GatewayCompression.payload) continue;

        test(
          '${payloadFormat.value.toUpperCase()} (${compression.name})',
          () => testClient(GatewayApiOptions(
            token: testToken!,
            intents: GatewayIntents.none,
            compression: compression,
            payloadFormat: payloadFormat,
          )),
        );
      }
    }

    test('Multiple shards', () async {
      const shardCount = 5;

      late NyxxGateway client;

      await expectLater(
        () async => client = await Nyxx.connectGatewayWithOptions(
          GatewayApiOptions(
            token: testToken!,
            intents: GatewayIntents.none,
            totalShards: shardCount,
          ),
        ),
        completes,
      );
      expect(client.gateway.messages.where((event) => event is ErrorReceived), emitsDone);
      for (int i = 0; i < shardCount; i++) {
        await expectLater(client.onEvent, emits(isA<ReadyEvent>()));
      }
      await expectLater(client.close(), completes);
    });
  });

  group('NyxxGateway', skip: testToken != null ? false : 'No test token provided', () {
    late NyxxGateway client;

    // Use setUpAll and tearDownAll to minimize the number of sessions opened on the test token.
    setUpAll(() async {
      client = await Nyxx.connectGateway(testToken!, GatewayIntents.allUnprivileged);

      if (testGuild != null) {
        await client.onGuildCreate.firstWhere((event) => event is GuildCreateEvent && event.guild.id == Snowflake.parse(testGuild));
      } else {
        await client.onReady.first;
      }
    });

    tearDownAll(() async {
      await client.close();
    });

    test('listGuildMembers', skip: testGuild != null ? false : 'No test guild provided', timeout: Timeout(Duration(minutes: 10)), () async {
      final guildId = Snowflake.parse(testGuild!);

      // We can't list all guild members since we don't have the GUILD_MEMBERS intent, so just search for the current user
      final currentUser = await client.user.get();

      await expectLater(client.gateway.listGuildMembers(guildId, query: currentUser.username).drain(), completes);
    });

    test('updatePresence', () async {
      client.updatePresence(PresenceBuilder(status: CurrentUserStatus.dnd, isAfk: false));
      await Future.delayed(const Duration(seconds: 5));
      client.updatePresence(PresenceBuilder(status: CurrentUserStatus.online, isAfk: false));
      await Future.delayed(const Duration(seconds: 5));
    });

    group('Gateway', () {
      test('latency', timeout: Timeout(Duration(minutes: 2)), () async {
        // Only wait if the client hasn't yet received a heartbeat ack.
        if (client.gateway.latency == Duration.zero) {
          await client.gateway.messages.firstWhere((element) => element is EventReceived && element.event is HeartbeatAckEvent);
        }

        expect(client.gateway.latency, greaterThan(Duration.zero));
      });
    });

    test('buffers messages until shard is ready', () async {
      // This test needs its own client as we need to send an event before the shard is ready
      final client = await Nyxx.connectGateway(testToken!, GatewayIntents.none);

      client.gateway.updatePresence(PresenceBuilder(status: CurrentUserStatus.idle, isAfk: false));

      expect(client.gateway.messages, neverEmits(isA<ErrorReceived>()));

      await expectLater(client.close(), completes);
    });

    test('rate limits gateway events', () async {
      for (int i = 0; i < 200; i++) {
        client.gateway.updatePresence(PresenceBuilder(status: CurrentUserStatus.idle, isAfk: false));
      }

      ErrorReceived? receivedError;

      final errorSubscription = client.gateway.messages.listen((event) {
        if (event is ErrorReceived) receivedError = event;
      });

      // Give time for the disconnection to occur, if any.
      await Future.delayed(Duration(seconds: 10));

      expect(receivedError, isNull);
      errorSubscription.cancel();
    });
  });
}
