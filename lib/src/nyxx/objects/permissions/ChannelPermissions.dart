part of nyxx;

/// Holds permissions for channel
class ChannelPermissions extends SnowflakeEntity {
  /// Type of entity
  String type;

  /// Permissions
  Permissions permissions;

  ChannelPermissions._new(Map<String, dynamic> raw) : super(new Snowflake(raw['id'] as String)) {
    permissions = new Permissions.fromOverwrite(
        0, raw['allow'] as int, raw['deny'] as int);
    type = raw['type'] as String;
  }
}
