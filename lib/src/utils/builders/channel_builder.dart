import 'package:nyxx/nyxx.dart';

/// Builder for creating mini channel instance
abstract class ChannelBuilder implements Builder {
  /// Name of the channel
  String? name;

  /// Type of channel
  ChannelType? type;

  /// Sorting position of the channel
  int? position;

  /// Id of the parent category for a channel
  SnowflakeEntity? parentChannel;

  /// The channel's permission overwrites
  List<PermissionOverrideBuilder>? permissionOverrides;

  @override
  RawApiMap build() => {
        if (name != null) "name": name,
        if (type != null) "type": type!.value,
        if (position != null) "position": position,
        if (parentChannel != null) "parent_id": parentChannel!.id.toString(),
        if (permissionOverrides != null) "permission_overwrites": permissionOverrides!.map((e) => e.build()).toList(),
      };
}

class VoiceChannelBuilder extends ChannelBuilder {
  /// Type of channel
  @override
  // ignore: overridden_fields
  ChannelType? type = ChannelType.voice;

  /// The bitrate (in bits) of the voice channel (voice only)
  int? bitrate;

  /// The user limit of the voice channel (voice only)
  int? userLimit;

  /// Amount of seconds a user has to wait before sending another message (0-21600);
  /// bots, as well as users with the permission manage_messages or manage_channel, are unaffected
  int? rateLimitPerUser;

  /// Channel voice region id, automatic when set to null
  String? rtcRegion = "";

  @override
  RawApiMap build() => {
        ...super.build(),
        if (bitrate != null) "bitrate": bitrate,
        if (userLimit != null) "user_limit": userLimit,
        if (rateLimitPerUser != null) "rate_limit_per_user": rateLimitPerUser,
        if (rtcRegion != "") "rtc_region": rtcRegion,
      };
}

class TextChannelBuilder extends ChannelBuilder {
  /// Type of channel
  @override
  // ignore: overridden_fields
  ChannelType? type = ChannelType.text;

  /// Channel topic (0-1024 characters)
  String? topic;

  /// Whether the channel is nsfw
  bool? nsfw;

  TextChannelBuilder();
  factory TextChannelBuilder.create(String name) {
    final builder = TextChannelBuilder();
    builder.name = name;
    return builder;
  }

  @override
  RawApiMap build() => {
        ...super.build(),
        if (topic != null) "topic": topic,
        if (nsfw != null) "nsfw": nsfw,
      };
}
