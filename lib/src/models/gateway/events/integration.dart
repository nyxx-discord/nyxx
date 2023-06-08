import 'package:nyxx/src/models/gateway/event.dart';
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
  IntegrationCreateEvent({required this.guildId, required this.integration});
}

/// {@template integration_update_event}
/// Emitted when an integration is updated.
/// {@endtemplate}
class IntegrationUpdateEvent extends DispatchEvent {
  /// The ID of the guild.
  final Snowflake guildId;

  // TODO
  //final Integration? oldIntegration;

  /// The updated integration.
  final Integration integration;

  /// {@macro integration_update_event}
  IntegrationUpdateEvent({required this.guildId, required this.integration});
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

  /// {@macro integration_delete_event}
  IntegrationDeleteEvent({required this.id, required this.guildId, required this.applicationId});
}
