import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';

abstract class GuildChannel implements Channel {
  Snowflake get guildId;

  int get position;

  List<PermissionOverwrite> get permissionOverwrites;

  String get name;

  bool get isNsfw;

  Snowflake? get parentId;

  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder);

  Future<void> deletePermissionOverwrite(Snowflake id);
}
