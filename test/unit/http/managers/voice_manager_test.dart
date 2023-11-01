import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_endpoint.dart';
import '../../../test_manager.dart';
import 'member_manager_test.dart';

final sampleVoiceState = {
  "channel_id": "157733188964188161",
  "user_id": "80351110224678912",
  "session_id": "90326bd25d71d39b9ef95b299e3872ff",
  "deaf": false,
  "mute": false,
  "self_deaf": false,
  "self_mute": true,
  "suppress": false,
  "request_to_speak_timestamp": "2021-03-31T18:45:31.297561+00:00",
  "member": sampleMemberNoUser,

  // The API reference says this field is always present, but it's missing in the sample
  "self_video": false,
};

void checkVoiceState(VoiceState state) {
  expect(state.guildId, isNull);
  expect(state.channelId, equals(Snowflake(157733188964188161)));
  expect(state.userId, equals(Snowflake(80351110224678912)));
  expect(state.sessionId, equals('90326bd25d71d39b9ef95b299e3872ff'));
  expect(state.isServerDeafened, isFalse);
  expect(state.isServerMuted, isFalse);
  expect(state.isSelfDeafened, isFalse);
  expect(state.isSelfMuted, isTrue);
  expect(state.isStreaming, isFalse);
  expect(state.isVideoEnabled, isFalse);
  expect(state.isSuppressed, isFalse);
  expect(state.requestedToSpeakAt, equals(DateTime.utc(2021, 3, 31, 18, 45, 31, 297, 561)));
  expect(state.member, isNotNull);
  checkMemberNoUser(state.member!, expectedUserId: Snowflake(80351110224678912));
}

final sampleVoiceRegion = {
  "id": "brazil",
  "custom": false,
  "deprecated": false,
  "optimal": false,
  "name": "Brazil",
};

void checkVoiceRegion(VoiceRegion region) {
  expect(region.id, equals('brazil'));
  expect(region.name, equals('Brazil'));
  expect(region.isOptimal, isFalse);
  expect(region.isDeprecated, isFalse);
  expect(region.isCustom, isFalse);
}

void main() {
  group('VoiceManager', () {
    late MockNyxx client;
    late VoiceManager manager;

    setUp(() {
      client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      manager = VoiceManager(client);
    });

    test('parseVoiceState', () {
      ParsingTest<VoiceManager, VoiceState, Map<String, Object?>>(
        name: 'parseVoiceState',
        source: sampleVoiceState,
        parse: (manager) => manager.parseVoiceState,
        check: checkVoiceState,
      ).runWithManager(manager);
    });

    test('parseVoiceRegion', () {
      ParsingTest<VoiceManager, VoiceRegion, Map<String, Object?>>(
        name: 'parseVoiceRegion',
        source: sampleVoiceRegion,
        parse: (manager) => manager.parseVoiceRegion,
        check: checkVoiceRegion,
      ).runWithManager(manager);
    });

    testEndpoint(
      name: 'listRegions',
      '/voice/regions',
      (client) => client.voice.listRegions(),
      response: [sampleVoiceRegion],
    );
  });
}
