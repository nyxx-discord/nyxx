part of nyxx;

/// Represents channel which is part of guild.
abstract class GuildChannel implements Channel {
  /// The channel's name.
  String name;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's position in the channel list.
  int position;

  /// Parent channel id
  Snowflake parentId;

  /// Indicates if channel is NSFW
  bool nsfw;

  /// Permissions overwrites for channel.
  List<ChannelPermissions> permissions;

  /// Emitted when channel is updated.
  Stream<ChannelUpdateEvent> onUpdate;

  StreamController<ChannelUpdateEvent> _onUpdate;

  // Initializes Guild channel
  void _initialize(Map<String, dynamic> raw, Guild guild) {
    _onUpdate = StreamController.broadcast();
    onUpdate = _onUpdate.stream;

    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.guild = guild;

    if (raw['parent_id'] != null) {
      this.parentId = Snowflake(raw['parent_id'] as String);
    }

    this.nsfw = raw['nsfw'] as bool;

    if (raw['permission_overwrites'] != null) {
      permissions = List();
      raw['permission_overwrites'].forEach((dynamic o) {
        permissions.add(ChannelPermissions._new(o as Map<String, dynamic>));
      });
    }
  }

  /// Allows to set permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermission(
      PermissionsBuilder perms, SnowflakeEntity id,
      {String auditReason = ""}) async {
    if (!(id is Role) || !(id is User))
      throw Exception("`id` property must be either Role or User");

    await this.client.http.send(
        "PUT", "/channels/${this.id}/permissions/${id.toString()}",
        body: perms._build()._build(), reason: auditReason);
  }

  /// Deletes permission overwrite for given User or Role [id]
  /// Throws if [id] isn't [User] or [Role]
  Future<void> deleteChannelPermission(SnowflakeEntity id,
      {String auditReason = ""}) async {
    if (!(id is Role) || !(id is User))
      throw Exception("`id` property must be either Role or User");

    await this.client.http.send("POST", "/channels/${this.id}/permissions/$id",
        reason: auditReason);
  }
}
