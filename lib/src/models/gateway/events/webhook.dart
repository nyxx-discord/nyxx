import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
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
  /// @nodoc
  WebhooksUpdateEvent({required super.gateway, required this.guildId, required this.channelId});

  /// The guild the webhook was updated in.
  PartialGuild get guild => gateway.client.guilds[guildId];

  /// The channel the webhook was updated in.
  PartialChannel get channel => gateway.client.channels[channelId];
}
