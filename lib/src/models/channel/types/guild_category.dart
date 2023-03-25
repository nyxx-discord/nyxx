import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';

class PartialGuildCategory extends PartialGuildChannel {
  PartialGuildCategory({required super.id, required super.manager});
}

class GuildCategory extends PartialGuildCategory implements GuildChannel {
  @override
  final Snowflake guildId;

  @override
  final bool isNsfw;

  @override
  final String name;

  @override
  final Snowflake? parentId;

  @override
  final List<PermissionOverwrite> permissionOverwrites;

  @override
  final int position;

  GuildCategory({
    required super.id,
    required super.manager,
    required this.guildId,
    required this.isNsfw,
    required this.name,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
  });

  @override
  ChannelType get type => ChannelType.guildCategory;
}
