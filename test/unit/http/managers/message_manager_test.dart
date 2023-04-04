import 'package:test/test.dart';
import 'package:nyxx/nyxx.dart';

import '../../../test_manager.dart';

void main() {
  final sampleMessage = {
    "reactions": [
      {
        "count": 1,
        "me": false,
        "emoji": {"id": null, "name": "🔥"}
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
    "type": 0
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
    expect(message.pinned, isFalse);
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
  }

  final sampleCrosspostedMessage = {
    "reactions": [
      {
        "count": 1,
        "me": false,
        "emoji": {"id": null, "name": "🔥"}
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
    expect(message.pinned, isFalse);
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

  testManager<Message, MessageManager>(
    'MessageManager',
    (config, client) => MessageManager(config, client, channelId: Snowflake.zero),
    RegExp(r'/channels/0/message/\d+'),
    sampleObject: sampleMessage,
    sampleMatches: checkMessage,
    additionalSampleObjects: [sampleCrosspostedMessage],
    additionalSampleMatchers: [checkCrosspostedMessage],
    additionalParsingTests: [],
    additionalEndpointTests: [],
    createBuilder: MessageBuilder(),
    updateBuilder: MessageUpdateBuilder(),
  );
}
