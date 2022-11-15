import 'package:nyxx/nyxx.dart';

/// Builder for creating mini channel instance
abstract class ChannelBuilder implements Builder {
  /// Name of the channel (1-100 characters)
  String? name;

  /// Id of the channel.
  /// When using the `channels` parameter on [GuildBuilder], this field within each channel object may be set to an integer placeholder, and will be replaced by the API upon consumption.
  /// Its purpose is to allow you to create `GUILD_CATEGORY` channels by setting the [parentChannel.id] field on any children to the category's id field. Category channels must be listed before any children.
  Snowflake? id;

  /// Type of channel
  ChannelType? type;

  /// Sorting position of the channel
  int? position;

  /// Id of the parent category for a channel
  SnowflakeEntity? parentChannel;

  /// The channel's permission overwrites
  List<PermissionOverrideBuilder>? permissionOverrides;

  ChannelBuilder._({
    this.id,
    this.name,
    this.parentChannel,
    this.permissionOverrides,
    this.position,
    this.type,
  });

  @override
  RawApiMap build() => {
        if (name != null) "name": name,
        if (id != null) "id": id!.toString(),
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

  VoiceChannelBuilder({
    super.id,
    super.name,
    super.parentChannel,
    super.permissionOverrides,
    super.position,
    this.bitrate,
    this.rateLimitPerUser,
    this.rtcRegion,
    this.userLimit,
  }) : super._();

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

  TextChannelBuilder({
    super.id,
    super.name,
    super.parentChannel,
    super.permissionOverrides,
    super.position,
    this.nsfw,
    this.topic,
  }) : super._();
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
