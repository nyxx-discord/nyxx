import 'package:nyxx/src/models/events/event.dart';
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
  SoundboardSoundCreateEvent({required super.client, required this.sound});
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
  SoundboardSoundUpdateEvent({required super.client, required this.sound, required this.oldSound});
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
  SoundboardSoundDeleteEvent({required super.client, required this.sound, required this.guildId, required this.soundId});

  PartialGuild get guild => client.guilds[guildId];
}

/// {@template soundboard_sounds_update_event}
/// Emitted when multiple guild soundboard sounds are updated.
/// {@endtemplate}
class SoundboardSoundsUpdateEvent extends DispatchEvent {
  /// The ID of the guild where the sounds were updated.
  final Snowflake guildId;

  /// The sounds that were updated.
  final List<SoundboardSound> sounds;

  /// The old sounds.
  final List<SoundboardSound?> oldSounds;

  /// {@macro soundboard_sounds_update_event}
  /// @nodoc
  SoundboardSoundsUpdateEvent({required super.client, required this.guildId, required this.sounds, required this.oldSounds});
}
