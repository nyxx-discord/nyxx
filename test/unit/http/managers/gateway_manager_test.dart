import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_endpoint.dart';
import '../../../test_manager.dart';

final sampleGateway = {"url": "wss://gateway.discord.gg/"};

void checkGateway(GatewayConfiguration configuration) {
  expect(configuration.url, equals(Uri(scheme: 'wss', host: 'gateway.discord.gg', path: '/')));
}

final sampleGatewayBot = {
  "url": "wss://gateway.discord.gg/",
  "shards": 9,
  "session_start_limit": {"total": 1000, "remaining": 999, "reset_after": 14400000, "max_concurrency": 1}
};

void checkGatewayBot(GatewayBot gateway) {
  expect(gateway.url, equals(Uri(scheme: 'wss', host: 'gateway.discord.gg', path: '/')));
  expect(gateway.shards, equals(9));
  expect(gateway.sessionStartLimit.total, equals(1000));
  expect(gateway.sessionStartLimit.remaining, equals(999));
  expect(gateway.sessionStartLimit.resetAfter, equals(Duration(milliseconds: 14400000)));
  expect(gateway.sessionStartLimit.maxConcurrency, equals(1));
}

final sampleActivity = {
  "details": "24H RL Stream for Charity",
  "state": "Rocket League",
  "name": "Twitch",
  "type": 1,
  "url": "https://www.twitch.tv/discord",
};

void checkActivity(Activity activity) {
  expect(activity.name, equals('Twitch'));
  expect(activity.type, equals(ActivityType.streaming));
  expect(activity.url, equals(Uri.parse('https://www.twitch.tv/discord')));
  expect(activity.createdAt, isNull);
  expect(activity.timestamps, isNull);
  expect(activity.applicationId, isNull);
  expect(activity.details, equals('24H RL Stream for Charity'));
  expect(activity.state, equals('Rocket League'));
  expect(activity.party, isNull);
  expect(activity.assets, isNull);
  expect(activity.secrets, isNull);
  expect(activity.isInstance, isNull);
  expect(activity.flags, isNull);
  expect(activity.buttons, isNull);
}

final sampleActivity2 = {
  "name": "Rocket League",
  "type": 0,
  "application_id": "379286085710381999",
  "state": "In a Match",
  "details": "Ranked Duos: 2-1",
  "timestamps": {"start": 15112000660000},
  "party": {
    "id": "9dd6594e-81b3-49f6-a6b5-a679e6a060d3",
    "size": [2, 2]
  },
  "assets": {"large_image": "351371005538729000", "large_text": "DFH Stadium", "small_image": "351371005538729111", "small_text": "Silver III"},
  "secrets": {
    "join": "025ed05c71f639de8bfaa0d679d7c94b2fdce12f",
    "spectate": "e7eb30d2ee025ed05c71ea495f770b76454ee4e0",
    "match": "4b2fdce12f639de8bfa7e3591b71a0d679d7c93f"
  }
};

void checkActivity2(Activity activity) {
  expect(activity.name, equals('Rocket League'));
  expect(activity.type, equals(ActivityType.game));
  expect(activity.url, isNull);
  expect(activity.createdAt, isNull);
  expect(activity.timestamps?.start, equals(DateTime.fromMillisecondsSinceEpoch(15112000660000)));
  expect(activity.applicationId, equals(Snowflake(379286085710381999)));
  expect(activity.details, equals('Ranked Duos: 2-1'));
  expect(activity.state, equals('In a Match'));
  expect(activity.party?.id, equals('9dd6594e-81b3-49f6-a6b5-a679e6a060d3'));
  expect(activity.party?.currentSize, equals(2));
  expect(activity.party?.maxSize, equals(2));
  expect(activity.assets?.largeImage, equals('351371005538729000'));
  expect(activity.assets?.largeText, equals('DFH Stadium'));
  expect(activity.assets?.smallImage, equals('351371005538729111'));
  expect(activity.assets?.smallText, equals('Silver III'));
  expect(activity.secrets?.join, equals('025ed05c71f639de8bfaa0d679d7c94b2fdce12f'));
  expect(activity.secrets?.spectate, equals('e7eb30d2ee025ed05c71ea495f770b76454ee4e0'));
  expect(activity.secrets?.match, equals('4b2fdce12f639de8bfa7e3591b71a0d679d7c93f'));
  expect(activity.isInstance, isNull);
  expect(activity.flags, isNull);
  expect(activity.buttons, isNull);
}

void main() {
  group('GatewayManager', () {
    test('parseGatewayConfiguration', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<GatewayManager, GatewayConfiguration, Map<String, Object?>>(
        name: 'parseGatewayConfiguration',
        source: sampleGateway,
        parse: (manager) => manager.parseGatewayConfiguration,
        check: checkGateway,
      ).runWithManager(GatewayManager(client));
    });

    test('parseGatewayBot', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<GatewayManager, GatewayBot, Map<String, Object?>>(
        name: 'parseGatewayBot',
        source: sampleGatewayBot,
        parse: (manager) => manager.parseGatewayBot,
        check: checkGatewayBot,
      ).runWithManager(GatewayManager(client));
    });

    test('parseActivity', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      ParsingTest<GatewayManager, Activity, Map<String, Object?>>(
        name: 'parseActivity',
        source: sampleActivity,
        parse: (manager) => (Map<String, Object?> raw) => manager.parseActivity(raw, client),
        check: checkActivity,
      ).runWithManager(GatewayManager(client));
    });

    testEndpoint(
      '/gateway',
      name: 'fetchGateway',
      (client) => client.gateway.fetchGatewayConfiguration(),
      response: sampleGateway,
    );

    testEndpoint(
      '/gateway/bot',
      name: 'fetchGatewayBot',
      (client) => client.gateway.fetchGatewayBot(),
      response: sampleGatewayBot,
    );
  });
}
