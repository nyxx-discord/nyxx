import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/utils/flags.dart';

class RoleColorsBuilder extends CreateBuilder<RoleColors> {
  DiscordColor primary;

  DiscordColor? secondary;

  DiscordColor? tertiary;

  RoleColorsBuilder({
    required this.primary,
    this.secondary,
    this.tertiary,
  });

  @override
  Map<String, Object?> build() => {
        'primary_color': primary.value,
        if (secondary != null) 'secondary_color': secondary!.value,
        if (tertiary != null) 'tertiary_color': tertiary!.value,
      };
}

// TODO(lexedia): Remove color.
class RoleBuilder extends CreateBuilder<Role> {
  String? name;

  Flags<Permissions>? permissions;

  bool? isHoisted;

  ImageBuilder? icon;

  String? unicodeEmoji;

  bool? isMentionable;

  RoleColorsBuilder? colors;

  RoleBuilder({
    this.name,
    this.permissions,
    @Deprecated('Use `colors.primary` instead') DiscordColor? color,
    this.isHoisted,
    this.icon,
    this.unicodeEmoji,
    this.isMentionable,
    this.colors,
  }) {
    if (color != null) {
      assert(colors == null, 'Cannot set color if colors is non-null');
      colors = RoleColorsBuilder(primary: color);
    }
  }

  @Deprecated('Use `colors.primary` instead.')
  DiscordColor? get color => colors?.primary;

  @Deprecated('Use `colors.primary` instead.')
  set color(DiscordColor? color) {
    if (color != null) {
      assert(colors == null, 'Cannot set color if colors is non-null');
      colors = RoleColorsBuilder(primary: color);
    } else {
      colors = null;
    }
  }

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (permissions != null) 'permissions': permissions!.value.toString(),
        if (isHoisted != null) 'hoist': isHoisted,
        if (icon != null) 'icon': icon!.buildDataString(),
        if (unicodeEmoji != null) 'unicode_emoji': unicodeEmoji,
        if (isMentionable != null) 'mentionable': isMentionable,
        if (colors != null) 'colors': colors!.build(),
      };
}

class RoleUpdateBuilder extends UpdateBuilder<Role> {
  String? name;

  Flags<Permissions>? permissions;

  bool? isHoisted;

  ImageBuilder? icon;

  String? unicodeEmoji;

  bool? isMentionable;

  RoleColorsBuilder? colors;

  RoleUpdateBuilder({
    this.name,
    this.permissions,
    @Deprecated('Use `colors.primary` instead.') DiscordColor? color,
    this.isHoisted,
    this.icon = sentinelImageBuilder,
    this.unicodeEmoji = sentinelString,
    this.isMentionable,
    this.colors,
  }) {
    if (color != null) {
      colors = RoleColorsBuilder(primary: color);
    }
  }

  @Deprecated('Use `colors.primary` instead.')
  DiscordColor? get color => colors?.primary;

  @Deprecated('Use `colors.primary` instead.')
  set color(DiscordColor? color) {
    if (color != null) {
      colors = RoleColorsBuilder(primary: color);
    } else {
      colors = null;
    }
  }

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (permissions != null) 'permissions': permissions!.value.toString(),
        if (isHoisted != null) 'hoist': isHoisted,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (!identical(unicodeEmoji, sentinelString)) 'unicode_emoji': unicodeEmoji,
        if (isMentionable != null) 'mentionable': isMentionable,
        if (colors != null) 'colors': colors!.build(),
      };
}
