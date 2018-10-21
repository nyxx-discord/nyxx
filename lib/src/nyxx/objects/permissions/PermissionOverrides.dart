part of nyxx;

/// Holds permissions for channel
class ChannelPermissions extends SnowflakeEntity {
  /// Type of entity
  String type;

  /// Permissions
  Permissions permissions;

  int allow;

  int deny;

  ChannelPermissions._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {

    this.allow = raw['allow'] as int;
    this.deny = raw['deny'] as int;

    permissions =
        Permissions.fromOverwrite(0, allow, deny);
    type = raw['type'] as String;
  }

  ChannelPermissions._synthetic(int value, Snowflake id) : super(id) {
    this.permissions = Permissions.fromInt(value);
  }
}
