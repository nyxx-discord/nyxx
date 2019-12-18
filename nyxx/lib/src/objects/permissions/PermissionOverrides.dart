part of nyxx;

/// Holds permissions overrides for channel
class PermissionsOverrides extends SnowflakeEntity {
  /// Type of entity
  String type;

  /// Permissions
  Permissions permissions;

  /// Value of permissions allowed
  int allow;

  /// Value of permissions denied
  int deny;

  PermissionsOverrides._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this.allow = raw['allow'] as int;
    this.deny = raw['deny'] as int;

    permissions = Permissions.fromOverwrite(0, allow, deny);
    type = raw['type'] as String;
  }

  PermissionsOverrides._synthetic(int value, Snowflake id) : super(id) {
    this.permissions = Permissions.fromInt(value);
  }
}
