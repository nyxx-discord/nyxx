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
      expect(client.gateway.messages.where((event) => event is ErrorReceived), emitsDone);
      await expectLater(client.onEvent, emits(isA<ReadyEvent>()));
      await expectLater(client.close(), completes);
    }

    test(
      'JSON (uncompressed)',
      () => testClient(GatewayApiOptions(
        token: testToken!,
        intents: GatewayIntents.none,
        compression: GatewayCompression.none,
        payloadFormat: GatewayPayloadFormat.json,
      )),
    );

    test(
      'JSON (payload compression)',
      () => testClient(GatewayApiOptions(
        token: testToken!,
        intents: GatewayIntents.none,
        compression: GatewayCompression.payload,
        payloadFormat: GatewayPayloadFormat.json,
      )),
    );

    test(
      'JSON (transport compression)',
      () => testClient(GatewayApiOptions(
        token: testToken!,
        intents: GatewayIntents.none,
        compression: GatewayCompression.transport,
        payloadFormat: GatewayPayloadFormat.json,
      )),
    );

    test(
      'ETF (uncompressed)',
      () => testClient(GatewayApiOptions(
        token: testToken!,
        intents: GatewayIntents.none,
        compression: GatewayCompression.none,
        payloadFormat: GatewayPayloadFormat.etf,
      )),
    );

    test(
      'ETF (transport compression)',
      () => testClient(GatewayApiOptions(
        token: testToken!,
        intents: GatewayIntents.none,
        compression: GatewayCompression.transport,
        payloadFormat: GatewayPayloadFormat.etf,
      )),
    );
  });

  group('NyxxGateway', skip: testToken != null ? false : 'No test token provided', () {
    late NyxxGateway client;

    // Use setUpAll and tearDownAll to minimize the number of sessions opened on the test token.
    setUpAll(() async {
      client = await Nyxx.connectGateway(testToken!, GatewayIntents.allUnprivileged);

      if (testGuild != null) {
        await client.onGuildCreate.firstWhere((event) => event is GuildCreateEvent && event.guild.id == Snowflake.parse(testGuild));
      }
    });

    tearDownAll(() async {
      await client.close();
    });

    test('listGuildMembers', skip: testGuild != null ? false : 'No test guild provided', timeout: Timeout(Duration(minutes: 10)), () async {
      final guildId = Snowflake.parse(testGuild!);

      // We can't list all guild members since we don't have the GUILD_MEMBERS intent, so just search for the current user
      final currentUser = await client.users.fetchCurrentUser();

      await expectLater(client.gateway.listGuildMembers(guildId, query: currentUser.username).drain(), completes);
    });

    test('updatePresence', () async {
      client.updatePresence(PresenceBuilder(status: CurrentUserStatus.dnd, isAfk: false));
      await Future.delayed(const Duration(seconds: 5));
      client.updatePresence(PresenceBuilder(status: CurrentUserStatus.online, isAfk: false));
      await Future.delayed(const Duration(seconds: 5));
    });
  });
}
