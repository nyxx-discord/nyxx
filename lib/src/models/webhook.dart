import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/webhook.dart';
import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/message/author.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/http/managers/webhook_manager.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';

/// A partial [Webhook].
class PartialWebhook extends WritableSnowflakeEntity<Webhook> {
  @override
  final WebhookManager manager;

  /// Create a new [PartialWebhook].
  /// @nodoc
  PartialWebhook({required super.id, required this.manager});

  /// Update this webhook, returning the updated webhook.
  ///
  /// External references:
  /// * [WebhookManager.update]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#modify-webhook
  @override
  Future<Webhook> update(WebhookUpdateBuilder builder, {String? token, String? auditLogReason}) =>
      manager.update(id, builder, token: token, auditLogReason: auditLogReason);

  /// Delete this webhook.
  ///
  /// External references:
  /// * [WebhookManager.delete]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#delete-webhook
  @override
  Future<void> delete({String? token, String? auditLogReason}) => manager.delete(id, token: token, auditLogReason: auditLogReason);

  /// Execute this webhook using its [token].
  ///
  /// If [wait] is `false`, `null` is returned and no errors are raised from the server. Otherwise, the created message is returned.
  ///
  /// If [threadId] is specified, the message is sent in that thread in this webhook's channel.
  ///
  /// External references:
  /// * [WebhookManager.execute]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#execute-webhook
  Future<Message?> execute(MessageBuilder builder,
          {required String token, bool? wait, Snowflake? threadId, String? threadName, List<Snowflake>? appliedTags, String? username, String? avatarUrl}) =>
      manager.execute(id, builder,
          token: token, wait: wait, threadId: threadId, threadName: threadName, appliedTags: appliedTags, username: username, avatarUrl: avatarUrl);

  /// Fetch a message sent by this webhook using its [token].
  ///
  /// If [threadId] is specified, the message is fetched in that thread in this webhook's channel.
  ///
  /// External references:
  /// * [WebhookManager.fetchWebhookMessage]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#get-webhook-message
  Future<Message> fetchMessage(Snowflake messageId, {required String token, Snowflake? threadId}) =>
      manager.fetchWebhookMessage(id, messageId, token: token, threadId: threadId);

  /// Update a message sent by this webhook using its [token].
  ///
  /// If [threadId] is specified, the message is updated in that thread in this webhook's channel.
  ///
  /// External references:
  /// * [WebhookManager.updateWebhookMessage]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#edit-webhook-message
  Future<Message> updateMessage(Snowflake messageId, MessageUpdateBuilder builder, {required String token, Snowflake? threadId}) =>
      manager.updateWebhookMessage(id, messageId, builder, token: token);

  /// Delete a message sent by this webhook using its [token].
  ///
  /// If [threadId] is specified, the message is deleted in that thread in this webhook's channel.
  ///
  /// External references:
  /// * [WebhookManager.deleteWebhookMessage]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#delete-webhook-message
  Future<void> deleteMessage(Snowflake messageId, {required String token, Snowflake? threadId}) =>
      manager.deleteWebhookMessage(id, messageId, token: token, threadId: threadId);
}

/// A partial [Webhook] sent as part of a [Message].
class WebhookAuthor extends PartialWebhook implements MessageAuthor {
  @override
  final String? avatarHash;

  @override
  final String username;

  /// Create a new [WebhookAuthor].
  /// @nodoc
  WebhookAuthor({required super.id, required super.manager, required this.avatarHash, required this.username});

  @override
  CdnAsset? get avatar => avatarHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..avatars(id: id.toString()),
          hash: avatarHash!,
        );
}

/// {@template webhook}
/// A non authenticated way to send messages to a Discord channel.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#webhook-resource
/// {@endtemplate}
class Webhook extends PartialWebhook {
  /// The type of this webhook.
  final WebhookType type;

  /// The ID of the guild this webhook is for, if any.
  final Snowflake? guildId;

  /// The ID of the channel this webhook is for, if any.
  final Snowflake? channelId;

  /// The user this webhook was created by.
  final User? user;

  /// The default name of this webhook.
  final String? name;

  /// The hash of this webhook's default avatar image.
  final String? avatarHash;

  /// If this is a [WebhookType.incoming] webhook, this webhook's token.
  final String? token;

  /// The ID of the application that created this webhook.
  final Snowflake? applicationId;

  final PartialGuild? sourceGuild;

  /// If this is a [WebhookType.channelFollower], this webhook's source channel.
  final PartialChannel? sourceChannel;

  /// The URL to use to execute the webhook.
  final Uri? url;

  /// {@macro webhook}
  /// @nodoc
  Webhook({
    required super.id,
    required super.manager,
    required this.type,
    required this.guildId,
    required this.channelId,
    required this.user,
    required this.name,
    required this.avatarHash,
    required this.token,
    required this.applicationId,
    required this.sourceGuild,
    required this.sourceChannel,
    required this.url,
  });

  /// The guild this webhook is for, if any.
  PartialGuild? get guild => guildId == null ? null : manager.client.guilds[guildId!];

  /// The channel this webhook is for, if any.
  PartialChannel? get channel => channelId == null ? null : manager.client.channels[channelId!];

  /// The application that created this webhook.
  PartialApplication? get application => applicationId == null ? null : manager.client.applications[applicationId!];
}

/// The type of a [Webhook].
final class WebhookType extends EnumLike<int, WebhookType> {
  /// A webhook which sends messages to a channel using a [Webhook.token].
  static const incoming = WebhookType(1);

  /// An internal webhook used to manage Channel Followers.
  static const channelFollower = WebhookType(2);

  /// A webhook for use with interactions.
  static const application = WebhookType(3);

  /// @nodoc
  const WebhookType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  WebhookType.parse(int value) : this(value);
}
