import 'dart:async';
import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN'];
  group('close and error handling', timeout: Timeout.parse('2m'), skip: testToken != null, () {
    Future<NyxxGateway> createClient([GatewayClientOptions? options]) async {
      return await Nyxx.connectGatewayWithOptions(
        GatewayApiOptions(
          token: testToken!,
          intents: GatewayIntents.allUnprivileged,
          totalShards: 2,
        ),
        options ?? GatewayClientOptions(),
      );
    }

    test('normal close', () async {
      final client = await createClient();

      expect(client.done, completes);
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, completes);
      expect(client.gateway.shards[0].done, completes);
      expect(client.gateway.shards[1].done, completes);

      expect(client.close(), completes);
    });

    test('HTTP handler close', () async {
      final client = await createClient();

      expect(client.done, throwsA(isA<NyxxException>()));
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, completes);
      expect(client.gateway.shards[0].done, completes);
      expect(client.gateway.shards[1].done, completes);

      expect(client.httpHandler.close(), completes);
    });

    test('Gateway close', () async {
      final client = await createClient();

      expect(client.done, throwsA(isA<NyxxException>()));
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, completes);
      expect(client.gateway.shards[0].done, completes);
      expect(client.gateway.shards[1].done, completes);

      expect(client.gateway.close(), completes);
    });

    test('Shard close', () async {
      final client = await createClient();

      expect(client.done, throwsA(isA<NyxxException>()));
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, throwsA(isA<NyxxException>()));
      expect(client.gateway.shards[0].done, completes);
      expect(client.gateway.shards[1].done, completes);

      expect(client.gateway.shards[0].close(), completes);
    });

    test('Shard isolate killed', () async {
      final client = await createClient();

      expect(client.done, throwsA(isA<NyxxException>()));
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, throwsA(isA<NyxxException>()));
      expect(client.gateway.shards[0].done, throwsA(isA<NyxxException>()));
      expect(client.gateway.shards[1].done, completes);

      client.gateway.shards[0].isolate.kill();
    });

    test('Shard disconnection error', () async {
      final client = await createClient(GatewayClientOptions(plugins: [FakeDisconnectPlugin()]));

      expect(client.done, throwsA(isA<NyxxException>()));
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, throwsA(isA<NyxxException>()));
      expect(client.gateway.shards[0].done, throwsA(isA<NyxxException>()));
      expect(client.gateway.shards[1].done, completes);
    });

    test('Shard reconnection error', () async {
      final options = ModifiableGatewayOptions();

      final client = await createClient(options);

      expect(client.done, throwsA(isA<NyxxException>()));
      expect(client.httpHandler.done, completes);
      expect(client.gateway.done, throwsA(isA<NyxxException>()));
      expect(client.gateway.shards[0].done, completes);
      expect(client.gateway.shards[1].done, completes);

      options.minimumSessionStarts = 1000000;
      client.gateway.shards[0].reconnect(allowResume: false);
    });
  });
}

class FakeDisconnectPlugin extends NyxxPlugin<NyxxGateway> {
  @override
  Stream<ShardMessage> interceptShardMessages(Shard shard, Stream<ShardMessage> messages) {
    final controller = StreamController<ShardMessage>();

    super.interceptShardMessages(shard, messages).listen((message) {
      controller.add(message);

      if (message case EventReceived(event: RawDispatchEvent(name: 'READY'))) {
        controller.add(Disconnecting(reason: 'Test forced disconnect'));
      }
    }, onDone: controller.close);

    return controller.stream;
  }
}

class ModifiableGatewayOptions extends GatewayClientOptions {
  @override
  // ignore: overridden_fields
  int minimumSessionStarts = 10;
}
