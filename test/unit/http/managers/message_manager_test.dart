import 'package:test/test.dart';
import 'package:nyxx/nyxx.dart';

import '../../../test_manager.dart';

final sampleMessage = {
  "reactions": [
    {
      "count": 1,
      "count_details": {
        "burst": 0,
        "normal": 1,
      },
      "me": false,
      "me_burst": false,
      "emoji": {"id": null, "name": "🔥"},
      "burst_colors": [],
    }
  ],
  "attachments": [],
  "tts": false,
  "embeds": [],
  "timestamp": "2017-07-11T17:27:07.299000+00:00",
  "mention_everyone": false,
  "id": "334385199974967042",
  "pinned": false,
  "edited_timestamp": null,
  "author": {"username": "Mason", "discriminator": "9999", "id": "53908099506183680", "avatar": "a_bab14f271d565501444b2ca3be944b25"},
  "mention_roles": [],
  "content": "Supa Hot",
  "channel_id": "290926798999357250",
  "mentions": [],
  "type": 0,
  "sticker_items": [
    {
      "id": "0",
      "name": "example sticker",
      "format_type": 1,
    }
  ]
};

void checkMessage(Message message) {
  expect(message.id, equals(Snowflake(334385199974967042)));
  expect(message.author.id, equals(Snowflake(53908099506183680)));
  expect(message.content, equals('Supa Hot'));
  expect(message.timestamp, equals(DateTime.utc(2017, 07, 11, 17, 27, 07, 299)));
  expect(message.editedTimestamp, isNull);
  expect(message.isTts, isFalse);
  expect(message.mentionsEveryone, isFalse);
  expect(message.mentions, isEmpty);
  expect(message.channelMentions, isEmpty);
  expect(message.attachments, isEmpty);
  expect(message.embeds, isEmpty);
  expect(message.reactions, hasLength(1));
  expect(message.reactions.single.count, equals(1));
  expect(message.reactions.single.me, isFalse);
  expect(message.nonce, isNull);
  expect(message.isPinned, isFalse);
  expect(message.webhookId, isNull);
  expect(message.type, equals(MessageType.normal));
  expect(message.activity, isNull);
  expect(message.applicationId, isNull);
  expect(message.reference, isNull);
  expect(message.flags, equals(MessageFlags(0)));
  expect(message.referencedMessage, isNull);
  expect(message.thread, isNull);
  expect(message.position, isNull);
  expect(message.roleSubscriptionData, isNull);
  expect(message.stickers, hasLength(1));
}

final sampleCrosspostedMessage = {
  "reactions": [
    {
      "count": 1,
      "count_details": {
        "burst": 0,
        "normal": 1,
      },
      "me": false,
      "me_burst": false,
      "emoji": {"id": null, "name": "🔥"},
      "burst_colors": [],
    }
  ],
  "attachments": [],
  "tts": false,
  "embeds": [],
  "timestamp": "2017-07-11T17:27:07.299000+00:00",
  "mention_everyone": false,
  "id": "334385199974967042",
  "pinned": false,
  "edited_timestamp": null,
  "author": {"username": "Mason", "discriminator": "9999", "id": "53908099506183680", "avatar": "a_bab14f271d565501444b2ca3be944b25"},
  "mention_roles": [],
  "mention_channels": [
    {"id": "278325129692446722", "guild_id": "278325129692446720", "name": "big-news", "type": 5}
  ],
  "content": "Big news! In this <#278325129692446722> channel!",
  "channel_id": "290926798999357250",
  "mentions": [],
  "type": 0,
  "flags": 2,
  "message_reference": {"channel_id": "278325129692446722", "guild_id": "278325129692446720", "message_id": "306588351130107906"}
};

void checkCrosspostedMessage(Message message) {
  expect(message.id, equals(Snowflake(334385199974967042)));
  expect(message.author.id, equals(Snowflake(53908099506183680)));
  expect(message.content, equals('Big news! In this <#278325129692446722> channel!'));
  expect(message.timestamp, equals(DateTime.utc(2017, 07, 11, 17, 27, 07, 299)));
  expect(message.editedTimestamp, isNull);
  expect(message.isTts, isFalse);
  expect(message.mentionsEveryone, isFalse);
  expect(message.mentions, isEmpty);
  expect(message.channelMentions, hasLength(1));
  expect(message.channelMentions.single.guildId, equals(Snowflake(278325129692446720)));
  expect(message.channelMentions.single.id, equals(Snowflake(278325129692446722)));
  expect(message.channelMentions.single.name, equals('big-news'));
  expect(message.channelMentions.single.type, equals(ChannelType.guildAnnouncement));
  expect(message.attachments, isEmpty);
  expect(message.embeds, isEmpty);
  expect(message.reactions, hasLength(1));
  expect(message.reactions.single.count, equals(1));
  expect(message.reactions.single.me, isFalse);
  expect(message.nonce, isNull);
  expect(message.isPinned, isFalse);
  expect(message.webhookId, isNull);
  expect(message.type, equals(MessageType.normal));
  expect(message.activity, isNull);
  expect(message.applicationId, isNull);
  expect(message.reference?.channelId, equals(Snowflake(278325129692446722)));
  expect(message.reference?.guildId, equals(Snowflake(278325129692446720)));
  expect(message.reference?.messageId, equals(Snowflake(306588351130107906)));
  expect(message.flags, equals(MessageFlags(2)));
  expect(message.referencedMessage, isNull);
  expect(message.thread, isNull);
  expect(message.position, isNull);
  expect(message.roleSubscriptionData, isNull);
}

final sampleMessageInteractionMetadata = {
  "id": "1234567891234567800",
  "type": 2,
  "user": {
    "id": "1234567891234567801",
    "username": "rizzedskibidi",
    "discriminator": "0000",
    "global_name": "Ultra Man",
    "flags": 256,
    "avatar": "a_abc123",
  },
  "authorizing_integration_owners": {
    "0": "1234567891234567802",
    "1": "1234567891234567803",
  },
  "original_response_message_id": "1234567891234567804",
  "interacted_message_id": "1234567891234567805",
  "triggering_interaction_metadata": {
    "id": "1234567891234567806",
    "type": 2,
    "user_id": "1234567891234567807",
    "authorizing_integration_owners": {
      "0": "1234567891234567808",
      "1": "1234567891234567809",
    },
  },
};

void checkMessageInteractionMetadata(MessageInteractionMetadata metadata) {
  expect(metadata.id, equals(Snowflake(1234567891234567800)));
  expect(metadata.type, equals(InteractionType.applicationCommand));
  expect(metadata.userId, equals(Snowflake(1234567891234567801)));
  expect(
      metadata.authorizingIntegrationOwners,
      equals({
        ApplicationIntegrationType.guildInstall: Snowflake(1234567891234567802),
        ApplicationIntegrationType.userInstall: Snowflake(1234567891234567803),
      }));
  expect(metadata.originalResponseMessageId, Snowflake(1234567891234567804));
  expect(metadata.interactedMessageId, Snowflake(1234567891234567805));
  expect(metadata.triggeringInteractionMetadata, isNotNull);
  MessageInteractionMetadata metadata2 = metadata.triggeringInteractionMetadata!;
  expect(metadata2.id, equals(Snowflake(1234567891234567806)));
  expect(metadata2.type, equals(InteractionType.applicationCommand));
  expect(metadata2.userId, equals(Snowflake(1234567891234567807)));
  expect(
      metadata2.authorizingIntegrationOwners,
      equals({
        ApplicationIntegrationType.guildInstall: Snowflake(1234567891234567808),
        ApplicationIntegrationType.userInstall: Snowflake(1234567891234567809),
      }));
  expect(metadata2.originalResponseMessageId, isNull);
  expect(metadata2.interactedMessageId, isNull);
  expect(metadata2.triggeringInteractionMetadata, isNull);
}

void main() {
  testManager<Message, MessageManager>(
    'MessageManager',
    (config, client) => MessageManager(config, client, channelId: Snowflake.zero),
    RegExp(r'/channels/0/messages/\d+'),
    '/channels/0/messages',
    sampleObject: sampleMessage,
    sampleMatches: checkMessage,
    additionalSampleObjects: [sampleCrosspostedMessage],
    additionalSampleMatchers: [checkCrosspostedMessage],
    createBuilder: MessageBuilder(),
    updateBuilder: MessageUpdateBuilder(),
    additionalParsingTests: [
      ParsingTest<MessageManager, MessageInteractionMetadata, Map<String, Object?>>(
        name: 'parseMessageInteractionMetadata',
        source: sampleMessageInteractionMetadata,
        parse: (manager) => manager.parseMessageInteractionMetadata,
        check: checkMessageInteractionMetadata,
      ),
    ],
    additionalEndpointTests: [
      EndpointTest<MessageManager, List<Message>, List<Object?>>(
        name: 'fetchMany',
        source: [sampleMessage],
        urlMatcher: '/channels/0/messages',
        execute: (manager) => manager.fetchMany(),
        check: (list) {
          expect(list, hasLength(1));
          checkMessage(list.single);
        },
      ),
      EndpointTest<MessageManager, Message, Map<String, Object?>>(
        name: 'crosspost',
        method: 'post',
        source: sampleCrosspostedMessage,
        urlMatcher: '/channels/0/messages/1/crosspost',
        execute: (manager) => manager.crosspost(Snowflake(1)),
        check: checkCrosspostedMessage,
      ),
      EndpointTest<MessageManager, void, void>(
        name: 'bulkDelete',
        method: 'post',
        source: null,
        urlMatcher: '/channels/0/messages/bulk-delete',
        execute: (manager) => manager.bulkDelete([Snowflake.zero]),
        check: (_) {},
      ),
      EndpointTest<MessageManager, List<Message>, List<Object?>>(
        name: 'getPins',
        source: [sampleMessage],
        urlMatcher: '/channels/0/pins',
        execute: (manager) => manager.getPins(),
        check: (list) {
          expect(list, hasLength(1));
          checkMessage(list.single);
        },
      ),
      EndpointTest<MessageManager, void, void>(
        name: 'pin',
        method: 'put',
        source: null,
        urlMatcher: '/channels/0/pins/1',
        execute: (manager) => manager.pin(Snowflake(1)),
        check: (_) {},
      ),
      EndpointTest<MessageManager, void, void>(
        name: 'unpin',
        method: 'delete',
        source: null,
        urlMatcher: '/channels/0/pins/1',
        execute: (manager) => manager.unpin(Snowflake(1)),
        check: (_) {},
      ),
    ],
  );
}
