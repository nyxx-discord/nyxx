part of nyxx;

/// Holds permissions overrides for channel
class PermissionsOverrides extends SnowflakeEntity implements Convertable<PermissionOverrideBuilder> {
  /// Type of entity. Either 0 (role) or 1 (member)
  late final int type;

  /// Permissions
  late final Permissions permissions;

  /// Value of permissions allowed
  late final int allow;

  /// Value of permissions denied
  late final int deny;

  PermissionsOverrides._new(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.allow = int.parse(raw["allow"] as String);
    this.deny = int.parse(raw["deny"] as String);

    this.permissions = Permissions.fromOverwrite(0, allow, deny);
    this.type = raw["type"] as int;
  }

  @override
  PermissionOverrideBuilder toBuilder() => PermissionOverrideBuilder.from(this.type, this.id, this.permissions);
}
