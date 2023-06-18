import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template webhooks_update_event}
/// Emitted when the webhooks in a channel are updated.
/// {@endtemplate}
class WebhooksUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the channel.
  final Snowflake channelId;

  /// {@macro webhooks_update_event}
  WebhooksUpdateEvent({required this.guildId, required this.channelId});
}
