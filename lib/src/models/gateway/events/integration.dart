import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template integration_create_event}
/// Emitted when an integration is created.
/// {@endtemplate}
class IntegrationCreateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The created integration.
  final Integration integration;

  /// {@macro integration_create_event}
  /// @nodoc
  IntegrationCreateEvent({required super.gateway, required this.guildId, required this.integration});

  /// The guild the integration was created in.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template integration_update_event}
/// Emitted when an integration is updated.
/// {@endtemplate}
class IntegrationUpdateEvent extends DispatchEvent {
  /// The ID of the guild
  final Snowflake guildId;

  /// The integration as it was cached before the update.
  final Integration? oldIntegration;

  /// The updated integration.
  final Integration integration;

  /// {@macro integration_update_event}
  /// @nodoc
  IntegrationUpdateEvent({required super.gateway, required this.guildId, required this.oldIntegration, required this.integration});

  /// The guild the integration was updated in.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// {@template integration_delete_event}
/// Emitted when an integration is deleted.
/// {@endtemplate}
class IntegrationDeleteEvent extends DispatchEvent {
  /// The ID of the deleted integration.
  final Snowflake id;

  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the application associated with the integration.
  final Snowflake? applicationId;

  /// The integration as it was cached before being deleted.
  final Integration? deletedIntegration;

  /// {@macro integration_delete_event}
  /// @nodoc
  IntegrationDeleteEvent({required super.gateway, required this.id, required this.guildId, required this.applicationId, required this.deletedIntegration});

  /// The guild the integration was deleted from.
  PartialGuild get guild => gateway.client.guilds[guildId];

  /// The application associated with the integration.
  PartialApplication? get application => applicationId == null ? null : gateway.client.applications[applicationId!];
}
