import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/thread_preview_channel.dart';
import 'package:nyxx/src/core/embed/embed.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/guild/webhook.dart';
import 'package:nyxx/src/core/message/attachment.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/message_flags.dart';
import 'package:nyxx/src/core/message/message_reference.dart';
import 'package:nyxx/src/core/message/message_time_stamp.dart';
import 'package:nyxx/src/core/message/message_type.dart';
import 'package:nyxx/src/core/message/reaction.dart';
import 'package:nyxx/src/core/message/referenced_message.dart';
import 'package:nyxx/src/core/message/sticker.dart';
import 'package:nyxx/src/core/message/components/message_component.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/internal/interfaces/disposable.dart';
import 'package:nyxx/src/internal/interfaces/message_author.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

abstract class IMessage implements SnowflakeEntity, Disposable, Convertable<MessageBuilder> {
  /// Reference to bot instance
  INyxx get client;

  /// The message's content.
  String get content;

  /// Channel in which message was sent
  CacheableTextChannel<ITextChannel> get channel;

  /// The timestamp of when the message was last edited, null if not edited.
  DateTime? get editedTimestamp;

  /// The message's author.
  IMessageAuthor get author;

  /// The mentions in the message.
  List<Cacheable<Snowflake, IUser>> get mentions;

  /// A collection of the embeds in the message.
  List<Embed> get embeds;

  /// The attachments in the message.
  List<IAttachment> get attachments;

  /// Whether or not the message is pinned.
  bool get pinned;

  /// Whether or not the message was sent with TTS enabled.
  bool get tts;

  /// Whether or @everyone was mentioned in the message.
  bool get mentionEveryone;

  /// List of message reactions
  List<IReaction> get reactions;

  /// Type of message
  MessageType get type;

  /// Extra features of the message
  MessageFlags? get flags;

  /// Returns clickable url to this message.
  String get url;

  /// The stickers sent with the message
  Iterable<IPartialSticker> get partialStickers;

  /// Message reply
  IReferencedMessage? get referencedMessage;

  /// List of components attached to message.
  List<List<IMessageComponent>> get components;

  /// A nonce that can be used for optimistic message sending (up to 25 characters)
  /// You will be able to identify that message when receiving it through gateway
  String? get nonce;

  /// If the message is a response to an Interaction, this is the id of the interaction's application
  Snowflake? get applicationId;

  /// Inline timestamps of current message
  Iterable<IMessageTimestamp> get timestamps;

  /// The message's guild.
  Cacheable<Snowflake, IGuild>? get guild;

  /// Member data of message author
  IMember? get member;

  /// Reference to original message if this message cross posts other message
  IMessageReference? get crossPostReference;

  /// True if this message is cross posts other message
  bool get isCrossPosting;

  // TODO: Consider how to handle properly webhooks as message authors.
  /// True if message is sent by a webhook
  bool get isByWebhook;

  /// Role mentions in this message
  List<Cacheable<Snowflake, IRole>> get roleMentions;

  /// Cross post a Message into all guilds what follow the news channel indicated.
  /// This endpoint requires the "DISCOVERY" feature to be present for the guild.
  Future<void> crossPost();

  /// Suppresses embeds in message. Can be executed in other users messages.
  Future<IMessage> suppressEmbeds();

  /// Edits the message.
  Future<IMessage> edit(MessageBuilder builder);

  /// Add reaction to message.
  Future<void> createReaction(IEmoji emoji);

  /// Deletes reaction of bot.
  Future<void> deleteSelfReaction(IEmoji emoji);

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(IEmoji emoji, SnowflakeEntity entity);

  /// Deletes all reactions
  Future<void> deleteAllReactions();

  /// Deletes the message.
  Future<void> delete({String? auditReason});

  /// Pins [Message] in message's channel
  Future<void> pinMessage();

  /// Unpins [Message] in message's channel
  Future<void> unpinMessage();

  /// Creates a thread based on this message, that only retrieves a [ThreadPreviewChannel]
  Future<IThreadPreviewChannel> createThread(ThreadBuilder builder);

  /// Creates a thread in a message
  Future<IThreadChannel> createAndGetThread(ThreadBuilder builder);
}

class Message extends SnowflakeEntity implements IMessage {
  /// Reference to bot instance
  @override
  final INyxx client;

  /// The message's author.
  @override
  late final IMessageAuthor author;

  /// The message's content.
  @override
  late String content;

  /// Channel in which message was sent
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// The timestamp of when the message was last edited, null if not edited.
  @override
  late final DateTime? editedTimestamp;

  /// The mentions in the message.
  @override
  List<Cacheable<Snowflake, IUser>> mentions = [];

  /// A collection of the embeds in the message.
  @override
  late List<Embed> embeds;

  /// The attachments in the message.
  @override
  late final List<Attachment> attachments;

  /// Whether or not the message is pinned.
  @override
  late final bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  @override
  late final bool tts;

  /// Whether or @everyone was mentioned in the message.
  @override
  late final bool mentionEveryone;

  /// List of message reactions
  @override
  late final List<Reaction> reactions;

  /// Type of message
  @override
  late final MessageType type;

  /// Extra features of the message
  @override
  late final MessageFlags? flags;

  /// The stickers sent with the message
  @override
  late final Iterable<IPartialSticker> partialStickers;

  /// Message reply
  @override
  late final ReferencedMessage? referencedMessage;

  /// List of components attached to message.
  @override
  late final List<List<IMessageComponent>> components;

  /// A nonce that can be used for optimistic message sending (up to 25 characters)
  /// You will be able to identify that message when receiving it through gateway
  @override
  late final String? nonce;

  /// If the message is a response to an Interaction, this is the id of the interaction's application
  @override
  late final Snowflake? applicationId;

  /// Inline timestamps of current message
  @override
  Iterable<IMessageTimestamp> get timestamps sync* {
    for (final match in IMessageTimestamp.regex.allMatches(content)) {
      yield MessageTimestamp(match);
    }
  }

  /// The message's guild.
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Reference to original message if this message cross posts other message
  @override
  late final IMessageReference? crossPostReference;

  /// True if this message is cross posts other message
  @override
  bool get isCrossPosting => crossPostReference != null;

  /// Returns clickable url to this message.
  @override
  String get url => "https://discordapp.com/channels/${guild?.id ?? '@me'}"
      "/${channel.id}/$id";

  /// Member data of message author
  @override
  late final IMember? member;

  // TODO: Consider how to handle properly webhooks as message authors.
  /// True if message is sent by a webhook
  @override
  bool get isByWebhook => author is IWebhook;

  /// Role mentions in this message
  @override
  late final List<Cacheable<Snowflake, IRole>> roleMentions;

  /// Creates na instance of [Message]
  Message(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    content = raw["content"] as String;
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["channel_id"]));

    pinned = raw["pinned"] as bool;
    tts = raw["tts"] as bool;
    mentionEveryone = raw["mention_everyone"] as bool;
    type = MessageType.from(raw["type"] as int);

    partialStickers = [
      if (raw["sticker_items"] != null)
        for (final rawSticker in raw["sticker_items"]) PartialSticker(rawSticker as RawApiMap, client)
    ];

    if (raw["flags"] != null) {
      flags = MessageFlags(raw["flags"] as int);
    }

    if (raw["edited_timestamp"] != null) {
      editedTimestamp = DateTime.parse(raw["edited_timestamp"] as String).toUtc();
    }

    embeds = [
      if (raw["embeds"] != null && raw["embeds"].isNotEmpty as bool)
        for (var r in raw["embeds"]) Embed(r as RawApiMap)
    ];

    attachments = [
      if (raw["attachments"] != null && raw["attachments"].isNotEmpty as bool)
        for (var r in raw["attachments"]) Attachment(r as RawApiMap)
    ];

    reactions = [
      if (raw["reactions"] != null && raw["reactions"].isNotEmpty as bool)
        for (var r in raw["reactions"]) Reaction(r as RawApiMap)
    ];

    if (raw["mentions"] != null && raw["mentions"].isNotEmpty as bool) {
      for (final rawUser in raw["mentions"]) {
        final user = User(client, rawUser as RawApiMap);

        if (client.cacheOptions.userCachePolicyLocation.objectConstructor) {
          client.users[user.id] = user;
        }

        mentions.add(UserCacheable(client, user.id));
      }
    }

    if (raw["type"] == 19) {
      referencedMessage = ReferencedMessage(client, raw);
    } else {
      referencedMessage = null;
    }

    if (raw["nonce"] != null) {
      nonce = raw["nonce"].toString();
    } else {
      nonce = null;
    }

    applicationId = raw["application_id"] != null ? Snowflake(raw["application_id"]) : null;

    if (raw["components"] != null) {
      components = [
        for (final rawRow in raw["components"]) [for (final componentRaw in rawRow["components"]) MessageComponent.deserialize(componentRaw as RawApiMap)]
      ];
    } else {
      components = [];
    }

    if (raw["message_reference"] != null) {
      crossPostReference = MessageReference(raw["message_reference"] as RawApiMap, client);
    } else {
      crossPostReference = null;
    }

    guild = raw["guild_id"] != null ? GuildCacheable(client, Snowflake(raw["guild_id"])) : null;

    if (raw["webhook_id"] != null) {
      author = Webhook(raw["author"] as RawApiMap, client);
    } else {
      author = User(client, raw["author"] as RawApiMap);

      if (client.cacheOptions.userCachePolicyLocation.objectConstructor) {
        client.users[author.id] = author as User;
      }
    }

    if (raw["member"] != null) {
      // In case member object doesnt have id property and we need it for member object
      raw["member"]["user"] = <String, dynamic>{"id": raw["author"]["id"]};
      member = Member(client, raw["member"] as RawApiMap, guild!.id);

      if (client.cacheOptions.memberCachePolicyLocation.objectConstructor && client.cacheOptions.memberCachePolicy.canCache(member!)) {
        guild?.getFromCache()?.members[member!.id] = member!;
      }
    }

    roleMentions = [
      if (raw["mention_roles"] != null)
        for (var roleId in raw["mention_roles"]) RoleCacheable(client, Snowflake(roleId), guild!)
    ];
  }

  /// Suppresses embeds in message. Can be executed in other users messages.
  @override
  Future<IMessage> suppressEmbeds() => client.httpEndpoints.suppressMessageEmbeds(channel.id, id);

  /// Edits the message.
  @override
  Future<IMessage> edit(MessageBuilder builder) => client.httpEndpoints.editMessage(channel.id, id, builder);

  /// Add reaction to message.
  @override
  Future<void> createReaction(IEmoji emoji) => client.httpEndpoints.createMessageReaction(channel.id, id, emoji);

  /// Deletes reaction of bot.
  @override
  Future<void> deleteSelfReaction(IEmoji emoji) => client.httpEndpoints.deleteMessageReaction(channel.id, id, emoji);

  /// Deletes reaction of given user.
  @override
  Future<void> deleteUserReaction(IEmoji emoji, SnowflakeEntity entity) => client.httpEndpoints.deleteMessageUserReaction(channel.id, id, emoji, entity.id);

  /// Deletes all reactions
  @override
  Future<void> deleteAllReactions() => client.httpEndpoints.deleteMessageAllReactions(channel.id, id);

  /// Deletes the message.
  @override
  Future<void> delete({String? auditReason}) => client.httpEndpoints.deleteMessage(channel.id, id);

  /// Pins [Message] in message's channel
  @override
  Future<void> pinMessage() => client.httpEndpoints.pinMessage(channel.id, id);

  /// Unpins [Message] in message's channel
  @override
  Future<void> unpinMessage() => client.httpEndpoints.unpinMessage(channel.id, id);

  /// Creates a thread based on this message, that only retrieves a [ThreadPreviewChannel]
  @override
  Future<IThreadPreviewChannel> createThread(ThreadBuilder builder) async => client.httpEndpoints.createThreadWithMessage(channel.id, id, builder);

  /// Creates a thread in a message
  @override
  Future<IThreadChannel> createAndGetThread(ThreadBuilder builder) async {
    final preview = await client.httpEndpoints.createThreadWithMessage(channel.id, id, builder);
    return preview.getThreadChannel().getOrDownload();
  }

  /// Cross post a Message into all guilds what follow the news channel indicated.
  /// This endpoint requires the "DISCOVERY" feature to be present for the guild.
  @override
  Future<void> crossPost() async => client.httpEndpoints.crossPostGuildMessage(channel.id, id);

  @override
  Future<void> dispose() => Future.value(null);

  @override
  MessageBuilder toBuilder() => MessageBuilder.fromMessage(this);

  @override
  bool operator ==(other) {
    if (other is Message) {
      return id == other.id;
    }

    if (other is Snowflake) {
      return id == other;
    }

    if (other is int) {
      return id == other;
    }

    if (other is String) {
      return id == other;
    }

    return false;
  }
}

class WebhookMessage extends Message {
  final Snowflake webhookId;
  final Snowflake? threadId;
  late final String? token;

  WebhookMessage(INyxx client, RawApiMap raw, this.webhookId, String? token, this.threadId) : super(client, raw) {
    this.token = token != null && token.isEmpty ? null : token;
  }

  /// Edits the message.
  @override
  Future<IMessage> edit(MessageBuilder builder) => client.httpEndpoints.editWebhookMessage(webhookId, id, builder, token: token, threadId: threadId);

  /// Deletes the message.
  @override
  Future<void> delete({String? auditReason}) =>
      client.httpEndpoints.deleteWebhookMessage(webhookId, id, token: token, threadId: threadId, auditReason: auditReason);
}
