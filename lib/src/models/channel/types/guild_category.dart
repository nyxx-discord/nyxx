import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';

class GuildCategory extends Channel implements GuildChannel {
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
  @override
  ChannelType get type => ChannelType.guildCategory;

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
  Future<void> deletePermissionOverwrite(Snowflake id) => manager.deletePermissionOverwrite(this.id, id);

  @override
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) => manager.updatePermissionOverwrite(id, builder);
}
