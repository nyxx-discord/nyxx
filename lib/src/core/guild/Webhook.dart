import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/Channel.dart';
import 'package:nyxx/src/core/channel/guild/TextGuildChannel.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/internal/interfaces/IMessageAuthor.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/IEnum.dart';
import 'package:nyxx/src/utils/builders/AttachmentBuilder.dart';
import 'package:nyxx/src/utils/builders/MessageBuilder.dart';

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
  int get hashCode => this.value.hashCode;
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
  Future<IMessage?> execute(MessageBuilder builder, {bool? wait, Snowflake? threadId, String? avatarUrl, String? username}) =>
      client.httpEndpoints.executeWebhook(this.id, builder, token: token, threadId: threadId, username: username, wait: wait, avatarUrl: avatarUrl);

  @override
  String avatarURL({String format = "webp", int size = 128}) => client.httpEndpoints.userAvatarURL(this.id, this.avatarHash, 0, format: format, size: size);

  /// Edits the webhook.
  Future<IWebhook> edit({String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason}) =>
      client.httpEndpoints.editWebhook(this.id, token: this.token, name: name, channel: channel, avatarAttachment: avatarAttachment, auditReason: auditReason);

  /// Deletes the webhook.
  Future<void> delete({String? auditReason}) => client.httpEndpoints.deleteWebhook(this.id, token: token, auditReason: auditReason);
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
  String get username => this.name.toString();

  @override
  int get discriminator => -1;

  @override
  bool get bot => true;

  @override
  String get tag => "";

  /// Reference to [NyxxWebsocket] object
  @override
  final INyxx client;

  /// Creates an instance of [Webhook]
  Webhook(RawApiMap raw, this.client) : super(Snowflake(raw["id"] as String)) {
    this.name = raw["name"] as String?;
    this.token = raw["token"] as String? ?? "";
    this.avatarHash = raw["avatar"] as String?;

    if (raw["type"] != null) {
      this.type = WebhookType.from(raw["type"] as int);
    } else {
      this.type = null;
    }

    if (raw["channel_id"] != null) {
      this.channel = CacheableTextChannel<TextGuildChannel>(client, Snowflake(raw["channel_id"]), ChannelType.text);
    } else {
      this.channel = null;
    }

    if (raw["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(raw["guild_id"] as String));
    } else {
      this.guild = null;
    }

    if (raw["user"] != null) {
      this.user = User(client, raw["user"] as RawApiMap);
    } else {
      this.user = null;
    }
  }

  /// Executes webhook.
  ///
  /// [wait] - waits for server confirmation of message send before response,
  /// and returns the created message body (defaults to false; when false a message that is not save does not return an error)
  @override
  Future<IMessage?> execute(MessageBuilder builder, {bool? wait, Snowflake? threadId, String? avatarUrl, String? username}) =>
      client.httpEndpoints.executeWebhook(this.id, builder, token: token, threadId: threadId, username: username, wait: wait, avatarUrl: avatarUrl);

  @override
  String avatarURL({String format = "webp", int size = 128}) => client.httpEndpoints.userAvatarURL(this.id, this.avatarHash, 0, format: format, size: size);

  /// Edits the webhook.
  @override
  Future<IWebhook> edit({String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason}) =>
      client.httpEndpoints.editWebhook(this.id, token: this.token, name: name, channel: channel, avatarAttachment: avatarAttachment, auditReason: auditReason);

  /// Deletes the webhook.
  @override
  Future<void> delete({String? auditReason}) => client.httpEndpoints.deleteWebhook(this.id, token: token, auditReason: auditReason);
}
