import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/webhook.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/http/managers/webhook_manager.dart';
import 'package:nyxx/src/models/user/user.dart';

class PartialWebhook extends SnowflakeEntity<Webhook> with SnowflakeEntityMixin<Webhook> {
  @override
  final WebhookManager manager;

  PartialWebhook({required super.id, required this.manager});

  Future<Webhook> update(WebhookUpdateBuilder builder, {String? token}) => manager.update(id, builder, token: token);

  Future<void> delete({String? token}) => manager.delete(id, token: token);

  Future<Message?> execute(MessageBuilder builder, {required String token, bool? wait}) => manager.execute(id, builder, token: token, wait: wait);

  Future<Message> fetchMessage(Snowflake messageId, {required String token, Snowflake? threadId}) =>
      manager.fetchWebhookMessage(id, messageId, token: token, threadId: threadId);

  Future<Message> updateMessage(Snowflake messageId, MessageUpdateBuilder builder, {required String token, Snowflake? threadId}) =>
      manager.updateWebhookMessage(id, messageId, builder, token: token);

  Future<void> deleteMessage(Snowflake messageId, {required String token, Snowflake? threadId}) =>
      manager.deleteWebhookMessage(id, messageId, token: token, threadId: threadId);
}

class Webhook extends PartialWebhook {
  final WebhookType type;

  final Snowflake? guildId;

  final Snowflake? channelId;

  final User? user;

  final String? name;

  final String? avatarHash;

  final String? token;

  final Snowflake? applicationId;

  // TODO
  // final PartialGuild? sourceGuild;

  final PartialChannel? sourceChannel;

  final Uri? url;

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

enum WebhookType {
  incoming._(1),
  channelFollower._(2),
  application._(3);

  final int value;

  const WebhookType._(this.value);

  factory WebhookType.parse(int value) => WebhookType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown webhook type', value),
      );

  @override
  String toString() => 'WebhookType($value)';
}
