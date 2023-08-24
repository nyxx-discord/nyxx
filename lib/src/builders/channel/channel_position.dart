import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ChannelPositionBuilder extends UpdateBuilder<GuildChannel> {
  Snowflake channelId;

  int? position;

  bool? lockPermissions;

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
