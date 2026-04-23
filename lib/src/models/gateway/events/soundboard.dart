import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/soundboard/soundboard.dart';

/// {@template soundboard_sound_create_event}
/// Emitted when a guild soundboard sound is created.
/// {@endtemplate}
///
/// {@category events}
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
///
/// {@category events}
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
///
/// {@category events}
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

/// {@template soundboard_sounds_update_event}
/// Emitted when multiple guild soundboard sounds are updated.
/// {@endtemplate}
///
/// {@category events}
class SoundboardSoundsUpdateEvent extends DispatchEvent {
  /// The ID of the guild where the sounds were updated.
  final Snowflake guildId;

  /// The sounds that were updated.
  final List<SoundboardSound> sounds;

  /// The old sounds.
  final List<SoundboardSound?> oldSounds;

  /// {@macro soundboard_sounds_update_event}
  /// @nodoc
  SoundboardSoundsUpdateEvent({required super.gateway, required this.guildId, required this.sounds, required this.oldSounds});

  /// The guild the sounds are for.
  PartialGuild get guild => gateway.client.guilds[guildId];
}

/// Sent in response to a soundboard sounds request.
///
/// {@category events}
class SoundboardSoundsEvent extends DispatchEvent {
  /// The ID of the [Guild] these sounds are for.
  final Snowflake guildId;

  /// The sounds in the specified guild.
  final List<SoundboardSound> sounds;

  /// @nodoc
  SoundboardSoundsEvent({required super.gateway, required this.guildId, required this.sounds});

  /// The guild the sounds are for.
  PartialGuild get guild => gateway.client.guilds[guildId];
}
