import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/snowflake.dart';

class IntegrationCreateEvent extends DispatchEvent {
  final Snowflake guildId;

  final Integration integration;

  IntegrationCreateEvent({required this.guildId, required this.integration});
}

class IntegrationUpdateEvent extends DispatchEvent {
  final Snowflake guildId;

  // TODO
  //final Integration? oldIntegration;

  final Integration integration;

  IntegrationUpdateEvent({required this.guildId, required this.integration});
}

class IntegrationDeleteEvent extends DispatchEvent {
  final Snowflake id;

  final Snowflake guildId;

  final Snowflake? applicationId;

  IntegrationDeleteEvent({required this.id, required this.guildId, required this.applicationId});
}
