import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ChannelPositionBuilder extends UpdateBuilder<GuildChannel> {
  /// The channel id to update.
  Snowflake channelId;

  /// The sorting position of the channel.
  int? position;

  /// Whether to sync the permission overwrites with the new parent if moving to a new category.
  bool? lockPermissions;

  /// The new parent ID for the channel that is moved.
  Snowflake? parentId;

  ChannelPositionBuilder({
    required this.channelId,
    this.position,
    this.lockPermissions,
    this.parentId,
  });

  @override
  Map<String, Object?> build() => {
        'id': channelId.toString(),
        if (position != null) 'position': position,
        if (lockPermissions != null) 'lock_permissions': lockPermissions,
        if (parentId != null) 'parent_id': parentId!.toString(),
      };
}
