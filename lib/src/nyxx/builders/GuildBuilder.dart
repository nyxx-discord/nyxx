part of nyxx;

/// Allows to build guild object for creating new one or modifying existing
class GuildBuilder implements Builder {
  /// Name of Guild
  String name;

  /// Voice region id
  String region;

  /// Base64 encoded 128x128 image
  String icon;

  /// Verification level
  int verificationLevel;

  /// Default message notification level
  int defaultMessageNotifications;

  /// Explicit content filter level
  int explicitContentFilter;

  /// List of roles to create at guild creation
  List<RoleBuilder> roles;

  /// List of channel to create at guild creation
  List<ChannelBuilder> channels;

  @override
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = Map();

    if (name != null) tmp['name'] = name;
    if (region != null) tmp['region'] = region;
    if (icon != null) tmp['icon'] = icon;
    if (verificationLevel != null)
      tmp['verification_level'] = verificationLevel;
    if (defaultMessageNotifications != null)
      tmp['default_message_notifications'] = defaultMessageNotifications;
    if (explicitContentFilter != null)
      tmp['explicit_content_filter'] = explicitContentFilter;
    if (roles != null) tmp['roles'] = _gen(roles);
    if (channels != null) tmp['channels'] = _gen(channels);

    return tmp;
  }

  Iterable<Map<String, dynamic>> _gen(List<Builder> lst) sync* {
    for (var e in lst) yield e._build();
  }
}

/// Creates role
class RoleBuilder implements Builder {
  /// Name of role
  String name;

  /// Integer representation of hexadecimal color code
  DiscordColor color;

  /// If this role is pinned in the user listing
  bool hoist;

  /// Position of role
  int position;

  /// Permission object for role
  PermissionsBuilder permission;

  /// Whether role is mentionable
  bool mentionable;

  RoleBuilder(this.name);

  @override
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = Map();

    tmp['name'] = name;
    if (color != null) tmp['color'] = color._value;
    if (hoist != null) tmp['hoist'] = hoist;
    if (position != null) tmp['position'] = position;
    if (permission != null) tmp['permission'] = permission._build()._build();
    if (mentionable != null) tmp['mentionable'] = mentionable;

    return tmp;
  }
}

/// Builder for creating mini channel instance
class ChannelBuilder implements Builder {
  /// Name of channel
  String name;

  /// Type of channel
  int type;

  ChannelBuilder(this.name, this.type);

  @override
  Map<String, dynamic> _build() {
    return {"name": name, "type": type};
  }
}
