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
  ],
  "poll": {
    "allow_multiselect": false,
    "answers": [
      {
        "answer_id": 1,
        "poll_media": {"text": "oof"},
      }
    ],
    "expiry": "2024-07-12T22:00:25.095257+00:00",
    "layout_type": 1,
    "question": {
      "text": "Why are you so dumb?",
    },
    "results": {
      "is_finalized": false,
      "answer_counts": [
        {
          "count": 1,
          "id": 1,
          "me_voted": true,
        }
      ]
    }
  }
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
  expect(message.poll, isNotNull);
  expect(message.poll!.allowsMultiselect, equals(false));
  expect(message.poll!.answers, hasLength(1));
  expect(message.poll!.answers.single.id, equals(1));
  expect(message.poll!.answers.single.pollMedia.text, equals('oof'));
  expect(message.poll!.endsAt, equals(DateTime.utc(2024, 07, 12, 22, 00, 25, 095, 257)));
  expect(message.poll!.layoutType, equals(PollLayoutType.defaultLayout));
  expect(message.poll!.question.text, equals('Why are you so dumb?'));
  expect(message.poll!.results, isNotNull);
  expect(message.poll!.results!.isFinalized, isFalse);
  expect(message.poll!.results!.answerCounts, hasLength(1));
  expect(message.poll!.results!.answerCounts.single.count, equals(1));
  expect(message.poll!.results!.answerCounts.single.answerId, equals(1));
  expect(message.poll!.results!.answerCounts.single.me, isTrue);
  expect(message.poll!.results!.answerCounts.single.count, equals(1));
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

final sampleForwardedMessage = {
  'type': 0,
  'tts': false,
  'timestamp': '2024-10-08T09:18:22.532000+00:00',
  'position': 0,
  'pinned': false,
  'nonce': '1293140413896458240',
  'message_snapshots': [
    {
      'message': {
        'type': 0,
        'timestamp': '2024-10-08T09:17:26.429000+00:00',
        'mentions': [],
        'flags': 0,
        'embeds': [],
        'edited_timestamp': null,
        'content': '<@&786646877335977984> I ping myself for self validation',
        'components': [],
        'attachments': []
      }
    }
  ],
  'message_reference': {
    'type': 1,
    'message_id': '1293140188952002611',
    'guild_id': '786638002399084594',
    'channel_id': '786638002399084597',
  },
  'mentions': [],
  'mention_roles': [],
  'mention_everyone': false,
  'member': {
    'roles': ['1034762811726901269'],
    'premium_since': null,
    'pending': false,
    'nick': null,
    'mute': false,
    'joined_at': '2022-10-23T10:03:13.019000+00:00',
    'flags': 2,
    'deaf': false,
    'communication_disabled_until': null,
    'banner': null,
    'avatar': null
  },
  'id': '1293140424264781887',
  'flags': 16384,
  'embeds': [],
  'edited_timestamp': null,
  'content': '',
  'components': [],
  'channel_id': '1038831656682930227',
  'author': {
    'username': 'abitofevrything',
    'public_flags': 128,
    'id': '506759329068613643',
    'global_name': 'Abitofevrything',
    'discriminator': '0',
    'clan': null,
    'avatar_decoration_data': null,
    'avatar': 'b591ea8a9d057669ea2a6cd3ab450301'
  },
  'attachments': [],
  'guild_id': '1033681997136146462',
};

void checkForwardedMessage(Message message) {
  expect(message.author.id, equals(Snowflake(506759329068613643)));
  expect(message.content, equals(''));
  expect(message.timestamp, equals(DateTime.utc(2024, 10, 08, 09, 18, 22, 532)));
  expect(message.editedTimestamp, isNull);
  expect(message.isTts, isFalse);
  expect(message.mentionsEveryone, isFalse);
  expect(message.mentions, equals([]));
  expect(message.roleMentionIds, equals([]));
  expect(message.channelMentions, equals([]));
  expect(message.attachments, equals([]));
  expect(message.embeds, equals([]));
  expect(message.reactions, equals([]));
  expect(message.nonce, equals('1293140413896458240'));
  expect(message.isPinned, isFalse);
  expect(message.webhookId, isNull);
  expect(message.type, MessageType.normal);
  expect(message.activity, isNull);
  expect(message.application, isNull);
  expect(message.applicationId, isNull);
  expect(message.reference, isNotNull);
  expect(message.reference!.type, equals(MessageReferenceType.forward));
  expect(message.reference!.messageId, equals(Snowflake(1293140188952002611)));
  expect(message.reference!.channelId, equals(Snowflake(786638002399084597)));
  expect(message.reference!.guildId, equals(Snowflake(786638002399084594)));
  expect(
    message.messageSnapshots,
    equals([
      wrapMatcher((MessageSnapshot snapshot) {
        expect(snapshot.timestamp, equals(DateTime.utc(2024, 10, 08, 09, 17, 26, 429)));
        expect(snapshot.editedTimestamp, isNull);
        expect(snapshot.type, MessageType.normal);
        expect(snapshot.content, equals('<@&786646877335977984> I ping myself for self validation'));
        expect(snapshot.attachments, equals([]));
        expect(snapshot.embeds, equals([]));
        expect(snapshot.flags, equals(MessageFlags(0)));
        expect(snapshot.mentions, equals([]));
        expect(
          snapshot.roleMentionIds,
          equals([
            // TODO: Update this once Discord properly populates this field.
          ]),
        );
      }),
    ]),
  );
  expect(message.flags, equals(MessageFlags(16384)));
  expect(message.referencedMessage, isNull);
  expect(message.interactionMetadata, isNull);
  expect(message.thread, isNull);
  expect(message.components, equals([]));
  expect(message.stickers, equals([]));
  expect(message.position, isNull);
  expect(message.roleSubscriptionData, isNull);
  expect(message.resolved, isNull);
  expect(message.poll, isNull);
  expect(message.call, isNull);
}

final sampleMessageInteractionMetadata = {
  "id": "1234567891234567800",
  "type": 2,
  "user": {
    "id": "1234567891234567801",
    "username": "rizzedskibidi",
    "discriminator": "0",
    "global_name": "Read if cute",
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
    "user": {
      "username": "nocap-fr",
      "discriminator": "0",
      "id": "1234567891234567807",
      "avatar": "a_abc123",
      "global_name": "Iloaf",
      "flags": 256,
    },
    "authorizing_integration_owners": {
      "0": "1234567891234567808",
      "1": "1234567891234567809",
    },
  },
};

void checkMessageInteractionMetadata(MessageInteractionMetadata metadata) {
  expect(metadata.id, equals(Snowflake(1234567891234567800)));
  expect(metadata.type, equals(InteractionType.applicationCommand));
  expect(metadata.user.id, equals(Snowflake(1234567891234567801)));
  expect(metadata.user.username, equals('rizzedskibidi'));
  expect(metadata.user.discriminator, equals('0'));
  expect(metadata.user.globalName, equals('Read if cute'));
  expect(metadata.user.flags, equals(UserFlags(256)));
  expect(metadata.user.avatarHash, equals('a_abc123'));
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
  expect(metadata2.user.id, equals(Snowflake(1234567891234567807)));
  expect(metadata2.user.username, equals('nocap-fr'));
  expect(metadata2.user.discriminator, equals('0'));
  expect(metadata2.user.globalName, equals('Iloaf'));
  expect(metadata2.user.flags, equals(UserFlags(256)));
  expect(metadata2.user.avatarHash, equals('a_abc123'));
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
    additionalSampleObjects: [sampleCrosspostedMessage, sampleForwardedMessage],
    additionalSampleMatchers: [checkCrosspostedMessage, checkForwardedMessage],
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
