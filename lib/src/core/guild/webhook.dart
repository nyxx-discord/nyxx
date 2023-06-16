import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/guild/text_guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/interfaces/message_author.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';

/// Type of webhook. Either [incoming] if it its normal webhook executable with token,
/// or [channelFollower] if its discord internal webhook
class WebhookType extends IEnum<int> {
  /// Incoming Webhooks can post messages to channels with a generated token
  static const WebhookType incoming = WebhookType._create(1);

  /// Channel Follower Webhooks are internal webhooks used with Channel Following to post new messages into channels
  static const WebhookType channelFollower = WebhookType._create(2);

  /// Creates instance of [WebhookType] from [value]. Default value is 0
  WebhookType.from(int? value) : super(value ?? 0);
  const WebhookType._create(int? value) : super(value ?? 0);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
abstract class IWebhook implements SnowflakeEntity, IMessageAuthor {
  /// The webhook's name.
  String? get name;

  /// The webhook's token. Defaults to empty string
  String get token;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  ICacheableTextChannel<ITextGuildChannel>? get channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  Cacheable<Snowflake, IGuild>? get guild;

  /// The user, if this is accessed using a normal client.
  IUser? get user;

  /// Webhook type
  WebhookType? get type;

  /// Webhooks avatar hash
  String? get avatarHash;

  /// Default webhook avatar id
  int get defaultAvatarId;

  /// Reference to [NyxxWebsocket] object
  INyxx get client;

  /// Executes webhook.
  ///
  /// [wait] - waits for server confirmation of message send before response,
  /// and returns the created message body (defaults to false; when false a message that is not save does not return an error)
  /// [threadId] is the id of thread in the channel to send to.
  /// If [threadName] is specified, this will create a thread in the forum channel with the given name - **this is only available for forum channels.**
  Future<IMessage?> execute(MessageBuilder builder, {bool wait = true, Snowflake? threadId, String? threadName, String? avatarUrl, String? username});

  @override
  String avatarUrl({String format = 'webp', int? size, bool animated = false});

  /// Edits the webhook.
  Future<IWebhook> edit({String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason});

  /// Deletes the webhook.
  Future<void> delete({String? auditReason});
}

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity implements IWebhook {
  /// The webhook's name.
  @override
  late final String? name;

  /// The webhook's token. Defaults to empty string
  @override
  late final String token;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  @override
  late final ICacheableTextChannel<ITextGuildChannel>? channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// The user, if this is accessed using a normal client.
  @override
  late final IUser? user;

  /// Webhook type
  @override
  late final WebhookType? type;

  /// Webhooks avatar hash
  @override
  late final String? avatarHash;

  /// Default webhook avatar id
  @override
  int get defaultAvatarId => 0;

  @override
  String get username => name.toString();

  @override
  late final int discriminator;

  @override
  bool get bot => true;

  @override
  String get tag => "";

  /// Reference to [NyxxWebsocket] object
  @override
  final INyxx client;

  @override
  bool get isInteractionWebhook => discriminator != -1;

  @override
  String get formattedDiscriminator => discriminator.toString().padLeft(4, "0");

  /// Creates an instance of [Webhook]
  Webhook(RawApiMap raw, this.client) : super(Snowflake(raw["id"] as String)) {
    name = raw["name"] as String? ?? raw['username'] as String?;
    token = raw["token"] as String? ?? "";
    avatarHash = raw["avatar"] as String?;
    discriminator = int.tryParse(raw['discriminator'] as String? ?? '-1') ?? -1;

    if (raw["type"] != null) {
      type = WebhookType.from(raw["type"] as int);
    } else {
      type = null;
    }

    if (raw["channel_id"] != null) {
      channel = CacheableTextChannel<TextGuildChannel>(client, Snowflake(raw["channel_id"]), ChannelType.text);
    } else {
      channel = null;
    }

    if (raw["guild_id"] != null) {
      guild = GuildCacheable(client, Snowflake(raw["guild_id"] as String));
    } else {
      guild = null;
    }

    if (raw["user"] != null) {
      user = User(client, raw["user"] as RawApiMap);
    } else {
      user = null;
    }
  }

  /// Executes webhook.
  ///
  /// [wait] - waits for server confirmation of message send before response,
  /// and returns the created message body (defaults to false; when false a message that is not save does not return an error)
  @override
  Future<IMessage?> execute(MessageBuilder builder, {bool wait = true, Snowflake? threadId, String? threadName, String? avatarUrl, String? username}) =>
      client.httpEndpoints
          .executeWebhook(id, builder, token: token, threadId: threadId, username: username, wait: wait, avatarUrl: avatarUrl, threadName: threadName);

  @override
  String avatarUrl({String format = 'webp', int? size, bool animated = false}) {
    if (avatarHash == null) {
      return client.cdnHttpEndpoints.defaultAvatar(defaultAvatarId, id.id);
    }

    return client.cdnHttpEndpoints.avatar(id, avatarHash!, format: format, size: size, animated: animated);
  }

  /// Edits the webhook.
  @override
  Future<IWebhook> edit({String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason}) =>
      client.httpEndpoints.editWebhook(id, token: token, name: name, channel: channel, avatarAttachment: avatarAttachment, auditReason: auditReason);

  /// Deletes the webhook.
  @override
  Future<void> delete({String? auditReason}) => client.httpEndpoints.deleteWebhook(id, token: token, auditReason: auditReason);
}
