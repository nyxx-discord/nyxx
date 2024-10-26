import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/events/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';
import 'package:nyxx/src/utils/enum_like.dart';

/// {@template voice_state_update_event}
/// Emitted when a user's voice state is updated.
/// {@endtemplate}
class VoiceStateUpdateEvent extends DispatchEvent {
  /// The updated voice state.
  final VoiceState state;

  /// The voice state as it was cached before the update.
  final VoiceState? oldState;

  /// {@macro voice_state_update_event}
  /// @nodoc
  VoiceStateUpdateEvent({required super.client, required this.oldState, required this.state});
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
  /// @nodoc
  VoiceServerUpdateEvent({required super.client, required this.token, required this.guildId, required this.endpoint});

  /// The guild.
  PartialGuild get guild => client.guilds[guildId];
}

/// {@template voice_channel_effect_send_event}
/// Emitted when someone sends an effect, such as an emoji reaction or a soundboard sound, in a voice channel the current user is connected to.
/// {@endtemplate}
class VoiceChannelEffectSendEvent extends DispatchEvent {
  /// The ID of the channel this effect was sent in.
  final Snowflake channelId;

  /// The ID of the guild this effect was sent in.
  final Snowflake guildId;

  /// The ID of the user who sent this effect.
  final Snowflake userId;

  /// The emoji sent, for emoji reaction and soundboard effects.
  final Emoji? emoji;

  /// The type of emoji animation, for emoji reaction and soundboard effects.
  final AnimationType? animationType;

  /// The ID of the emoji animation, for emoji reaction and soundboard effects.
  final int? animationId;

  /// The ID of the soundboard sound, for soundboard effects.
  final Snowflake? soundId;

  /// The volume of the soundboard sound, from 0 to 1, for soundboard effects.
  final double? soundVolume;

  /// {@macro voice_channel_effect_send_event}
  /// @nodoc
  VoiceChannelEffectSendEvent({
    required super.client,
    required this.channelId,
    required this.guildId,
    required this.userId,
    required this.emoji,
    required this.animationType,
    required this.animationId,
    required this.soundId,
    required this.soundVolume,
  });

  /// The channel this effect was sent in.
  PartialChannel get channel => client.channels[channelId];

  /// The guild this effect was sent in.
  PartialGuild get guild => client.guilds[guildId];

  /// The user who sent this effect.
  PartialUser get user => client.users[userId];
}

final class AnimationType extends EnumLike<int, AnimationType> {
  static const premium = AnimationType(1);
  static const basic = AnimationType(2);

  /// @nodoc
  const AnimationType(super.value);
}
