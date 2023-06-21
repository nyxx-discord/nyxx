import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/utils/flags.dart';

class RoleBuilder extends CreateBuilder<Role> {
  final String? name;

  final Flags<Permissions>? permissions;

  final DiscordColor? color;

  final bool? isHoisted;

  final ImageBuilder? icon;

  final String? unicodeEmoji;

  final bool? isMentionable;

  RoleBuilder({
    this.name,
    this.permissions,
    this.color,
    this.isHoisted,
    this.icon,
    this.unicodeEmoji,
    this.isMentionable,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (permissions != null) 'permissions': permissions!.value.toString(),
        if (color != null) 'color': color!.value,
        if (isHoisted != null) 'hoisted': isHoisted,
        if (icon != null) 'icon': icon!.buildDataString(),
        if (unicodeEmoji != null) 'unicode_emoji': unicodeEmoji,
        if (isMentionable != null) 'mentionable': isMentionable,
      };
}

class RoleUpdateBuilder extends UpdateBuilder<Role> {
  final String? name;

  final Permissions? permissions;

  final DiscordColor? color;

  final bool? isHoisted;

  final ImageBuilder? icon;

  final String? unicodeEmoji;

  final bool? isMentionable;

  RoleUpdateBuilder({
    this.name,
    this.permissions,
    this.color,
    this.isHoisted,
    this.icon = sentinelImageBuilder,
    this.unicodeEmoji = sentinelString,
    this.isMentionable,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (permissions != null) 'permissions': permissions!.value.toString(),
        if (color != null) 'color': color!.value,
        if (isHoisted != null) 'hoisted': isHoisted,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (!identical(unicodeEmoji, sentinelString)) 'unicode_emoji': unicodeEmoji,
        if (isMentionable != null) 'mentionable': isMentionable,
      };
}
