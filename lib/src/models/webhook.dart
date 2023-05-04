import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/webhook.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/http/managers/webhook_manager.dart';
import 'package:nyxx/src/models/user/user.dart';

/// A partial [Webhook].
class PartialWebhook extends SnowflakeEntity<Webhook> with SnowflakeEntityMixin<Webhook> {
  @override
  final WebhookManager manager;

  /// Create a new [PartialWebhook].
  PartialWebhook({required super.id, required this.manager});

  /// Update this webhook, returning the updated webhook.
  ///
  /// External references:
  /// * [WebhookManager.update]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#modify-webhook
  Future<Webhook> update(WebhookUpdateBuilder builder, {String? token}) => manager.update(id, builder, token: token);

  /// Delete this webhook.
  ///
  /// External references:
  /// * [WebhookManager.delete]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/webhook#delete-webhook
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
  Future<Message?> execute(MessageBuilder builder, {required String token, bool? wait, Snowflake? threadId}) =>
      manager.execute(id, builder, token: token, wait: wait, threadId: threadId);

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

  // TODO
  // final PartialGuild? sourceGuild;

  /// If this is a [WebhookType.channelFollower], this webhook's source channel.
  final PartialChannel? sourceChannel;

  /// The URL to use to execute the webhook.
  final Uri? url;

  /// {@macro webhook}
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
    required this.sourceChannel,
    required this.url,
  });
}

/// The type of a [Webhook].
enum WebhookType {
  /// A webhook which sends messages to a channel using a [Webhook.token].
  incoming._(1),

  /// An internal webhook used to manage Channel Followers.
  channelFollower._(2),

  /// A webhook for use with interactions.
  application._(3);

  /// The value of this webhook type.
  final int value;

  const WebhookType._(this.value);

  /// Parse a [WebhookType] from a [value].
  ///
  /// The [value] must be a valid webhook type.
  factory WebhookType.parse(int value) => WebhookType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown webhook type', value),
      );

  @override
  String toString() => 'WebhookType($value)';
}
