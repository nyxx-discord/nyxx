import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class GuildTemplate with ToStringHelper {
  final String code;

  final String name;

  final String? description;

  final int usageCount;

  final Snowflake creatorId;

  final User creator;

  final DateTime createdAt;

  final DateTime updatedAt;

  final Snowflake sourceGuildId;

  final Guild serializedSourceGuild;

  final bool? isDirty;

  GuildTemplate({
    required this.code,
    required this.name,
    required this.description,
    required this.usageCount,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.sourceGuildId,
    required this.serializedSourceGuild,
    required this.isDirty,
  });
}
