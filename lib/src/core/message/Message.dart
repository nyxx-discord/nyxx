import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/core/channel/ThreadPreviewChannel.dart';
import 'package:nyxx/src/core/embed/Embed.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/guild/Role.dart';
import 'package:nyxx/src/core/guild/Webhook.dart';
import 'package:nyxx/src/core/message/Attachment.dart';
import 'package:nyxx/src/core/message/Emoji.dart';
import 'package:nyxx/src/core/message/MessageFlags.dart';
import 'package:nyxx/src/core/message/MessageReference.dart';
import 'package:nyxx/src/core/message/MessageTimeStamp.dart';
import 'package:nyxx/src/core/message/MessageType.dart';
import 'package:nyxx/src/core/message/Reaction.dart';
import 'package:nyxx/src/core/message/ReferencedMessage.dart';
import 'package:nyxx/src/core/message/Sticker.dart';
import 'package:nyxx/src/core/message/components/MessageComponent.dart';
import 'package:nyxx/src/core/user/Member.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/internal/interfaces/Convertable.dart';
import 'package:nyxx/src/internal/interfaces/Disposable.dart';
import 'package:nyxx/src/internal/interfaces/IMessageAuthor.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/MessageBuilder.dart';
import 'package:nyxx/src/utils/builders/ThreadBuilder.dart';

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
  late final Iterable<IPartialSticker> partialStickers;

  /// Message reply
  IReferencedMessage? get referencedMessage;

  /// List of components attached to message.
  late final List<List<IMessageComponent>> components;

  /// A nonce that can be used for optimistic message sending (up to 25 characters)
  /// You will be able to identify that message when receiving it through gateway
  late final String? nonce;

  /// If the message is a response to an Interaction, this is the id of the interaction's application
  late final Snowflake? applicationId;

  /// Inline timestamps of current message
  Iterable<IMessageTimestamp> get timestamps;

  /// The message's guild.
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Member data of message author
  late final IMember? member;

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
    for (final match in IMessageTimestamp.regex.allMatches(this.content)) {
      yield MessageTimestamp(match);
    }
  }

  /// The message's guild.
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Reference to original message if this message cross posts other message
  late final IMessageReference? crossPostReference;

  /// True if this message is cross posts other message
  bool get isCrossPosting => this.crossPostReference != null;

  /// Returns clickable url to this message.
  @override
  String get url => "https://discordapp.com/channels/${this.guild?.id ?? '@me'}"
      "/${this.channel.id}/${this.id}";

  /// Member data of message author
  @override
  late final IMember? member;

  // TODO: Consider how to handle properly webhooks as message authors.
  /// True if message is sent by a webhook
  bool get isByWebhook => author is IWebhook;

  /// Role mentions in this message
  late final List<Cacheable<Snowflake, IRole>> roleMentions;

  /// Creates na instance of [Message]
  Message(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    this.content = raw["content"] as String;
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["channel_id"]));

    this.pinned = raw["pinned"] as bool;
    this.tts = raw["tts"] as bool;
    this.mentionEveryone = raw["mention_everyone"] as bool;
    this.type = MessageType.from(raw["type"] as int);

    this.partialStickers = [
      if (raw["sticker_items"] != null)
        for (final rawSticker in raw["sticker_items"]) PartialSticker(rawSticker as RawApiMap, client)
    ];

    if (raw["flags"] != null) {
      this.flags = MessageFlags(raw["flags"] as int);
    }

    if (raw["edited_timestamp"] != null) {
      this.editedTimestamp = DateTime.parse(raw["edited_timestamp"] as String).toUtc();
    }

    this.embeds = [
      if (raw["embeds"] != null && raw["embeds"].isNotEmpty as bool)
        for (var r in raw["embeds"]) Embed(r as RawApiMap)
    ];

    this.attachments = [
      if (raw["attachments"] != null && raw["attachments"].isNotEmpty as bool)
        for (var r in raw["attachments"]) Attachment(r as RawApiMap)
    ];

    this.reactions = [
      if (raw["reactions"] != null && raw["reactions"].isNotEmpty as bool)
        for (var r in raw["reactions"]) Reaction(r as RawApiMap)
    ];

    if (raw["mentions"] != null && raw["mentions"].isNotEmpty as bool) {
      for (final rawUser in raw["mentions"]) {
        final user = User(client, rawUser as RawApiMap);

        if (client.cacheOptions.userCachePolicyLocation.objectConstructor) {
          this.client.users[user.id] = user;
        }

        this.mentions.add(UserCacheable(client, user.id));
      }
    }

    if (raw["type"] == 19) {
      this.referencedMessage = ReferencedMessage(client, raw);
    } else {
      this.referencedMessage = null;
    }

    if (raw["nonce"] != null) {
      this.nonce = raw["nonce"].toString();
    } else {
      this.nonce = null;
    }

    this.applicationId = raw["application_id"] != null ? Snowflake(raw["application_id"]) : null;

    if (raw["components"] != null) {
      this.components = [
        for (final rawRow in raw["components"]) [for (final componentRaw in rawRow["components"]) MessageComponent.deserialize(componentRaw as RawApiMap)]
      ];
    } else {
      this.components = [];
    }

    if (raw["message_reference"] != null) {
      this.crossPostReference = MessageReference(raw["message_reference"] as RawApiMap, client);
    }

    this.guild = raw["guild_id"] != null ? GuildCacheable(client, Snowflake(raw["guild_id"])) : null;

    if (raw["webhook_id"] != null) {
      this.author = Webhook(raw["author"] as RawApiMap, client);
    } else {
      this.author = User(client, raw["author"] as RawApiMap);

      if (client.cacheOptions.userCachePolicyLocation.objectConstructor) {
        this.client.users[this.author.id] = this.author as User;
      }
    }

    if (raw["member"] != null) {
      // In case member object doesnt have id property and we need it for member object
      raw["member"]["user"] = <String, dynamic>{"id": raw["author"]["id"]};
      this.member = Member(client, raw["member"] as RawApiMap, this.guild!.id);

      if (client.cacheOptions.memberCachePolicyLocation.objectConstructor && client.cacheOptions.memberCachePolicy.canCache(member!)) {
        this.guild?.getFromCache()?.members[member!.id] = member!;
      }
    }

    this.roleMentions = [
      if (raw["mention_roles"] != null)
        for (var roleId in raw["mention_roles"]) RoleCacheable(client, Snowflake(roleId), this.guild!)
    ];
  }

  /// Suppresses embeds in message. Can be executed in other users messages.
  @override
  Future<IMessage> suppressEmbeds() => client.httpEndpoints.suppressMessageEmbeds(this.channel.id, this.id);

  /// Edits the message.
  @override
  Future<IMessage> edit(MessageBuilder builder) => client.httpEndpoints.editMessage(this.channel.id, this.id, builder);

  /// Add reaction to message.
  @override
  Future<void> createReaction(IEmoji emoji) => client.httpEndpoints.createMessageReaction(this.channel.id, this.id, emoji);

  /// Deletes reaction of bot.
  @override
  Future<void> deleteSelfReaction(IEmoji emoji) => client.httpEndpoints.deleteMessageReaction(this.channel.id, this.id, emoji);

  /// Deletes reaction of given user.
  @override
  Future<void> deleteUserReaction(IEmoji emoji, SnowflakeEntity entity) =>
      client.httpEndpoints.deleteMessageUserReaction(this.channel.id, this.id, emoji, entity.id);

  /// Deletes all reactions
  @override
  Future<void> deleteAllReactions() => client.httpEndpoints.deleteMessageAllReactions(this.channel.id, this.id);

  /// Deletes the message.
  @override
  Future<void> delete({String? auditReason}) => client.httpEndpoints.deleteMessage(this.channel.id, this.id);

  /// Pins [Message] in message's channel
  @override
  Future<void> pinMessage() => client.httpEndpoints.pinMessage(this.channel.id, this.id);

  /// Unpins [Message] in message's channel
  @override
  Future<void> unpinMessage() => client.httpEndpoints.unpinMessage(this.channel.id, this.id);

  /// Creates a thread based on this message, that only retrieves a [ThreadPreviewChannel]
  @override
  Future<IThreadPreviewChannel> createThread(ThreadBuilder builder) async => client.httpEndpoints.createThreadWithMessage(this.channel.id, this.id, builder);

  /// Creates a thread in a message
  @override
  Future<IThreadChannel> createAndGetThread(ThreadBuilder builder) async {
    final preview = await client.httpEndpoints.createThreadWithMessage(this.channel.id, this.id, builder);
    return preview.getThreadChannel().getOrDownload();
  }

  /// Cross post a Message into all guilds what follow the news channel indicated.
  /// This endpoint requires the "DISCOVERY" feature to be present for the guild.
  @override
  Future<void> crossPost() async => client.httpEndpoints.crossPostGuildMessage(this.channel.id, this.id);

  @override
  Future<void> dispose() => Future.value(null);

  @override
  MessageBuilder toBuilder() => MessageBuilder.fromMessage(this);

  @override
  bool operator ==(other) {
    if (other is Message) {
      return this.id == other.id;
    }

    if (other is Snowflake) {
      return this.id == other;
    }

    if (other is int) {
      return this.id == other;
    }

    if (other is String) {
      return this.id == other;
    }

    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
