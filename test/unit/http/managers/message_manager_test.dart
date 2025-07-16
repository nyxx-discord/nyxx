import 'package:nyxx/src/models/message/message.dart';
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
    'primary_guild': {
      'identity_guild_id': '1234647491267808778',
      'identity_enabled': true,
      'tag': 'DISC',
      'badge': '7d1734ae5a615e82bc7a4033b98fade8',
    },
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
        return true;
      }),
    ]),
  );
  expect(message.flags, equals(MessageFlags(16384)));
  expect(message.referencedMessage, isNull);
  expect(message.interactionMetadata, isNull);
  expect(message.thread, isNull);
  expect(message.components, equals([]));
  expect(message.stickers, equals([]));
  expect(message.position, equals(0));
  expect(message.roleSubscriptionData, isNull);
  expect(message.resolved, isNull);
  expect(message.poll, isNull);
  expect(message.call, isNull);
}

final sampleComponentsV2Message = {
  "type": 20,
  "content": "",
  "mentions": [],
  "mention_roles": [],
  "attachments": [],
  "embeds": [],
  "timestamp": "2025-02-24T21:01:48.409000+00:00",
  "edited_timestamp": null,
  "flags": 32768,
  "components": [
    {
      "type": 17,
      "id": 1,
      "accent_color": null,
      "components": [
        {
          "type": 9,
          "id": 2,
          "components": [
            {"type": 10, "id": 3, "content": "Hey there,"},
            {"type": 10, "id": 4, "content": "This is delightful, no?"}
          ],
          "accessory": {
            "type": 11,
            "id": 5,
            "media": {
              "url": "https://i.imgur.com/SpCbHBI.jpeg",
              "proxy_url": "https://images-ext-1.discordapp.net/external/JnxJ6nc07YuYZoa1zhTq2JW6oHVNJh4fDcTKElOG1F8/https/i.imgur.com/SpCbHBI.jpeg",
              "width": 640,
              "height": 640,
              "placeholder": "GSkKFwQ7d3dgiXiHeKZXWJd2eL+Y94wK",
              "placeholder_version": 1,
              "content_scan_metadata": {"version": 1, "flags": 0},
              "content_type": "image/jpeg",
              "loading_state": 2,
              "flags": 0
            },
            "description": "Meow meow meow meow meow, cat picture kanged.",
            "spoiler": false
          }
        },
        {
          "type": 12,
          "id": 6,
          "items": [
            {
              "media": {
                "url": "https://i.imgur.com/JOKsNeT.jpeg",
                "proxy_url": "https://images-ext-1.discordapp.net/external/oCSJtivfxPV1p3Al4__kvn8gU8K6j7RmAR6Ko0biOZs/https/i.imgur.com/JOKsNeT.jpeg",
                "width": 455,
                "height": 759,
                "placeholder": "GCkKJAZpi6t7h2X1logwUgZUZQ==",
                "placeholder_version": 1,
                "content_scan_metadata": {"version": 1, "flags": 0},
                "content_type": "image/jpeg",
                "loading_state": 2,
                "flags": 0
              },
              "description": "Meow meow meeow meeooow... Meow meow meow meeeeemeow.....",
              "spoiler": true
            },
            {
              "media": {
                "url": "https://i.imgur.com/ujAO1Dl.mp4",
                "proxy_url": "https://images-ext-1.discordapp.net/external/uNxJUvhDjfQJhhgf9Kb2_qHA1gVTpCr4_vrpv57sZVk/https/i.imgur.com/ujAO1Dl.mp4",
                "width": 575,
                "height": 1024,
                "placeholder": "nAgGDAIYAok4d2qqKFkwuwVlWg==",
                "placeholder_version": 1,
                "content_scan_metadata": {"version": 1, "flags": 0},
                "content_type": "image/jpeg",
                "loading_state": 2,
                "flags": 0
              },
              "description": "The fun never ends, cozy and cuddly [...]",
              "spoiler": false
            }
          ]
        },
        {
          "type": 13,
          "id": 7,
          "file": {
            "url":
                "https://cdn.discordapp.com/attachments/1317207732318900244/1343689362105176104/file.txt?ex=67c6c17c&is=67c56ffc&hm=925fdd61fd515ba4c6710f5440fdd4e3fef1ab278e4da1f3df9cbc05b90e7a2e&",
            "proxy_url":
                "https://media.discordapp.net/attachments/1317207732318900244/1343689362105176104/file.txt?ex=67c6c17c&is=67c56ffc&hm=925fdd61fd515ba4c6710f5440fdd4e3fef1ab278e4da1f3df9cbc05b90e7a2e&",
            "width": 0,
            "height": 0,
            "placeholder": null,
            "placeholder_version": null,
            "content_scan_metadata": {"version": 1, "flags": 0},
            "content_type": "text/plain; charset=utf-8",
            "loading_state": 2,
            "flags": 0
          },
          "name": "file.txt",
          "size": 67,
          "spoiler": false
        },
        {"type": 10, "id": 8, "content": "HELP THIS JSON IS BIG :sob:"},
        {"type": 14, "id": 9, "spacing": 2, "divider": true},
        {"type": 10, "id": 10, "content": "Finally it's over"}
      ],
      "spoiler": false
    }
  ],
  "resolved": {"users": <String, dynamic>{}, "members": <String, dynamic>{}, "channels": <String, dynamic>{}, "roles": <String, dynamic>{}},
  "id": "1343689361862168628",
  "channel_id": "1317207732318900244",
  "author": {
    "id": "925720548477136917",
    "username": "Cogmaster",
    "avatar": "2e84c5cbae01b86253d2b6bf29c5c9f5",
    "discriminator": "8910",
    "public_flags": 0,
    "flags": 0,
    "bot": true,
    "banner": null,
    "accent_color": null,
    "global_name": null,
    "avatar_decoration_data": null,
    "banner_color": null,
    "clan": null,
    "primary_guild": null
  },
  "pinned": false,
  "mention_everyone": false,
  "tts": false,
  "application_id": "925720548477136917",
  "interaction": {
    "id": "1343689360519725056",
    "type": 2,
    "name": "test",
    "user": {
      "id": "739575055503327324",
      "username": "the.furry",
      "avatar": "f5d94aa59dc42ec02bf357dc87811d39",
      "discriminator": "0",
      "public_flags": 128,
      "flags": 128,
      "banner": null,
      "accent_color": null,
      "global_name": "Pedro.js",
      "avatar_decoration_data": null,
      "banner_color": null,
      "clan": null,
      "primary_guild": null
    }
  },
  "webhook_id": "925720548477136917",
  "position": 0,
  "interaction_metadata": {
    "id": "1343689360519725056",
    "type": 2,
    "user": {
      "id": "739575055503327324",
      "username": "the.furry",
      "avatar": "f5d94aa59dc42ec02bf357dc87811d39",
      "discriminator": "0",
      "public_flags": 128,
      "flags": 128,
      "banner": null,
      "accent_color": null,
      "global_name": "Pedro.js",
      "avatar_decoration_data": null,
      "banner_color": null,
      "clan": null,
      "primary_guild": null
    },
    "authorizing_integration_owners": {"0": "1317206872763404478"},
    "name": "test",
    "command_type": 1
  }
};

void checkComponentsV2Message(Message message) {
  expect(message.author, (MessageAuthor author) {
    expect(author, isA<WebhookAuthor>());
    author as WebhookAuthor;

    expect(author.id, equals(Snowflake(925720548477136917)));
    return true;
  });
  expect(message.content, isEmpty);
  expect(message.timestamp, equals(DateTime.utc(2025, 02, 24, 21, 01, 48, 409)));
  expect(message.editedTimestamp, isNull);
  expect(message.isTts, isFalse);
  expect(message.mentionsEveryone, isFalse);
  expect(message.mentions, isEmpty);
  expect(message.roleMentionIds, isEmpty);
  expect(message.channelMentions, isEmpty);
  expect(message.attachments, isEmpty);
  expect(message.embeds, isEmpty);
  expect(message.reactions, isEmpty);
  expect(message.nonce, isNull);
  expect(message.isPinned, isFalse);
  expect(message.webhookId, equals(Snowflake(925720548477136917)));
  expect(message.type, equals(MessageType.chatInputCommand));
  expect(message.activity, isNull);
  expect(message.application, isNull);
  expect(message.applicationId, equals(Snowflake(925720548477136917)));
  expect(message.reference, isNull);
  expect(message.messageSnapshots, isNull);
  expect(message.flags, (MessageFlags flags) {
    expect(flags.hasComponentsV2, isTrue);
    return true;
  });
  expect(message.referencedMessage, isNull);
  expect(message.components, (List<MessageComponent>? components) {
    expect(components, isNotNull);
    expect(components, hasLength(1));

    expect(components!.single, isA<ContainerComponent>());
    expect(components.single, (ContainerComponent component) {
      expect(component.id, equals(1));
      expect(component.accentColor, isNull);

      expect(component.components, hasLength(6));
      expect(component.components.first, isA<SectionComponent>());
      expect(component.components.first, (SectionComponent component) {
        expect(component.id, equals(2));

        expect(component.components, everyElement(isA<TextDisplayComponent>()));
        expect(component.accessory, isA<ThumbnailComponent>());
        expect(component.accessory, (ThumbnailComponent component) {
          expect(component.description, equals('Meow meow meow meow meow, cat picture kanged.'));
          expect(component.isSpoiler, isFalse);
          expect(component.media.url, Uri.https('i.imgur.com', '/SpCbHBI.jpeg'));

          return true;
        });

        return true;
      });
      return true;
    });

    return true;
  });
  expect(message.stickers, isEmpty);
  expect(message.position, isZero);
  expect(message.roleSubscriptionData, isNull);
  expect(message.resolved, isNotNull);
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

final samplePinList = {
  'items': [
    {
      'pinned_at': '2024-10-08T09:18:22.532000+00:00',
      'message': sampleMessage,
    },
  ],
  'has_more': false,
};

void main() {
  testManager<Message, MessageManager>(
    'MessageManager',
    (config, client) => MessageManager(config, client, channelId: Snowflake.zero),
    RegExp(r'/channels/0/messages/\d+'),
    '/channels/0/messages',
    sampleObject: sampleMessage,
    sampleMatches: checkMessage,
    additionalSampleObjects: [sampleCrosspostedMessage, sampleForwardedMessage, sampleComponentsV2Message],
    additionalSampleMatchers: [checkCrosspostedMessage, checkForwardedMessage, checkComponentsV2Message],
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
        // ignore: deprecated_member_use_from_same_package
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
        urlMatcher: '/channels/0/messages/pins/1',
        execute: (manager) => manager.pin(Snowflake(1)),
        check: (_) {},
      ),
      EndpointTest<MessageManager, void, void>(
        name: 'unpin',
        method: 'delete',
        source: null,
        urlMatcher: '/channels/0/messages/pins/1',
        execute: (manager) => manager.unpin(Snowflake(1)),
        check: (_) {},
      ),
      EndpointTest<MessageManager, PinList, Map<String, Object?>>(
        name: 'listPins',
        source: samplePinList,
        urlMatcher: '/channels/0/messages/pins',
        execute: (manager) => manager.listPins(),
        check: (pinList) {
          expect(pinList.items, hasLength(1));
          checkMessage(pinList.items.single.message);
          expect(pinList.hasMore, isFalse);
        },
      ),
    ],
  );
}
