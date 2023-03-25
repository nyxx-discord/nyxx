import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';

class PartialGuildChannel extends PartialChannel {
  PartialGuildChannel({required super.id, required super.manager});
}

abstract class GuildChannel extends PartialGuildChannel implements Channel {
  final Snowflake guildId;

  final int position;

  final List<PermissionOverwrite> permissionOverwrites;

  final String name;

  final bool isNsfw;

  final Snowflake? parentId;

  GuildChannel({
    required super.id,
    required super.manager,
    required this.guildId,
    required this.position,
    required this.permissionOverwrites,
    required this.name,
    required this.isNsfw,
    required this.parentId,
  });
}
