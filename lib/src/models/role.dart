import 'package:nyxx/src/http/managers/role_manager.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class PartialRole extends SnowflakeEntity<Role> with SnowflakeEntityMixin<Role> {
  @override
  final RoleManager manager;

  PartialRole({required super.id, required this.manager});
}

class Role extends PartialRole {
  final String name;

  final DiscordColor color;

  final bool isHoisted;

  final String? iconHash;

  final String? unicodeEmoji;

  final int position;

  final Permissions permissions;

  final bool isMentionable;

  final RoleTags? tags;

  Role({
    required super.id,
    required super.manager,
    required this.name,
    required this.color,
    required this.isHoisted,
    required this.iconHash,
    required this.unicodeEmoji,
    required this.position,
    required this.permissions,
    required this.isMentionable,
    required this.tags,
  });
}

class RoleTags with ToStringHelper {
  final Snowflake? botId;

  final Snowflake? integrationId;

  final Snowflake? subscriptionListingId;

  RoleTags({
    required this.botId,
    required this.integrationId,
    required this.subscriptionListingId,
  });
}
