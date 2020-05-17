part of nyxx;

/// Allows to build guild object for creating new one or modifying existing
class GuildBuilder implements Builder {
  /// Name of Guild
  String? name;

  /// Voice region id
  String? region;

  /// Base64 encoded 128x128 image
  String? icon;

  /// Verification level
  int? verificationLevel;

  /// Default message notification level
  int? defaultMessageNotifications;

  /// Explicit content filter level
  int? explicitContentFilter;

  /// List of roles to create at guild creation
  List<RoleBuilder>? roles;

  /// List of channel to create at guild creation
  List<ChannelBuilder>? channels;

  @override
  Map<String, dynamic> _build() =>
    <String, dynamic>{
      if (name != null) "name": name,
      if (region != null) "region": region,
      if (icon != null) "icon": icon,
      if (verificationLevel != null) "verification_level": verificationLevel,
      if (defaultMessageNotifications != null) "default_message_notifications": defaultMessageNotifications,
      if (explicitContentFilter != null) "explicit_content_filter": explicitContentFilter,
      if (roles != null) "roles": _genIterable(roles!),
      if (channels != null) "channels": _genIterable(channels!)
    };

  Iterable<Map<String, dynamic>> _genIterable(List<Builder> list) sync* {
    for (final e in list) {
      yield e._build();
    }
  }
}

/// Creates role
class RoleBuilder implements Builder {
  /// Name of role
  String name;

  /// Integer representation of hexadecimal color code
  DiscordColor? color;

  /// If this role is pinned in the user listing
  bool? hoist;

  /// Position of role
  int? position;

  /// Permission object for role
  PermissionsBuilder? permission;

  /// Whether role is mentionable
  bool? mentionable;

  /// Creates role
  RoleBuilder(this.name);

  @override
  Map<String, dynamic> _build() => <String, dynamic>{
        "name": name,
        if (color != null) "color": color!._value,
        if (hoist != null) "hoist": hoist,
        if (position != null) "position": position,
        if (permission != null) "permission": permission!._build()._build(),
        if (mentionable != null) "mentionable": mentionable,
      };
}

/// Builder for creating mini channel instance
class ChannelBuilder implements Builder {
  /// Name of channel
  String name;

  /// Type of channel
  ChannelType type;

  /// Builder for creating mini channel instance
  ChannelBuilder(this.name, this.type);

  @override
  Map<String, dynamic> _build() => {"name": name, "type": type._value};
}
