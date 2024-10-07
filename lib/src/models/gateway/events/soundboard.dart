import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/soundboard/soundboard.dart';

/// {@template soundboard_sound_create_event}
/// Emitted when a guild soundboard sound is created.
/// {@endtemplate}
class SoundboardSoundCreateEvent extends DispatchEvent {
  /// The sound that was created.
  final SoundboardSound sound;

  /// {@macro soundboard_sound_create_event}
  /// @nodoc
  SoundboardSoundCreateEvent({required super.gateway, required this.sound});
}

/// {@template soundboard_sound_update_event}
/// Emitted when a guild soundboard sound is updated.
/// {@endtemplate}
class SoundboardSoundUpdateEvent extends DispatchEvent {
  /// The sound that was updated.
  final SoundboardSound sound;

  /// The old sound.
  final SoundboardSound? oldSound;

  /// {@macro soundboard_sound_update_event}
  /// @nodoc
  SoundboardSoundUpdateEvent({required super.gateway, required this.sound, required this.oldSound});
}

/// {@template soundboard_sound_delete_event}
/// Emitted when a guild soundboard sound is deleted.
/// {@endtemplate}
class SoundboardSoundDeleteEvent extends DispatchEvent {
  /// The sound that was deleted.
  final SoundboardSound? sound;

  /// The guild ID where the sound was deleted.
  final Snowflake guildId;

  /// The sound ID that was deleted.
  final Snowflake soundId;

  /// {@macro soundboard_sound_delete_event}
  /// @nodoc
  SoundboardSoundDeleteEvent({required super.gateway, required this.sound, required this.guildId, required this.soundId});

  PartialGuild get guild => gateway.client.guilds[guildId];
}
