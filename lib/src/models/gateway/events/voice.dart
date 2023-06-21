import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

/// {@template voice_state_update_event}
/// Emitted when a user's voice state is updated.
/// {@endtemplate}
class VoiceStateUpdateEvent extends DispatchEvent {
  /// The updated voice state.
  final VoiceState state;

  /// The voice state as it was cached before the update.
  final VoiceState? oldState;

  /// {@macro voice_state_update_event}
  VoiceStateUpdateEvent({required super.gateway, required this.oldState, required this.state});
}

/// {@template voice_server_update_event}
/// Emitted when joining a voice channel to update the voice servers.
/// {@endtemplate}
class VoiceServerUpdateEvent extends DispatchEvent {
  /// The voice token.
  final String token;

  /// The ID of the guild.
  final Snowflake guildId;

  /// The endpoint to connect to.
  final String? endpoint;

  /// {@macro voice_server_update_event}
  VoiceServerUpdateEvent({required super.gateway, required this.token, required this.guildId, required this.endpoint});

  /// The guild.
  PartialGuild get guild => gateway.client.guilds[guildId];
}
