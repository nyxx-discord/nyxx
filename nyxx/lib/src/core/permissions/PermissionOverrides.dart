part of nyxx;

/// Holds permissions overrides for channel
class PermissionsOverrides extends SnowflakeEntity implements Convertable<PermissionOverrideBuilder> {
  /// Type of entity
  late final String type;

  /// Permissions
  late final Permissions permissions;

  /// Value of permissions allowed
  late final int allow;

  /// Value of permissions denied
  late final int deny;

  PermissionsOverrides._new(Map<String, dynamic> raw) : super(Snowflake(raw["id"] as String)) {
    this.allow = raw["allow"] as int;
    this.deny = raw["deny"] as int;

    this.permissions = Permissions.fromOverwrite(0, allow, deny);
    this.type = raw["type"] as String;
  }

  @override
  PermissionOverrideBuilder toBuilder() => PermissionOverrideBuilder.from(this.type, this.id, this.permissions);
}
