part of nyxx;

/// Represents channel which is part of guild
abstract class GuildChannel implements Channel {
  /// The channel's name.
  String name;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's position in the channel list.
  int position;

  /// Parent channel id;
  Snowflake parentId;

  /// Indicates if channel is NSFW
  bool nsfw;

  /// Permissions for channel
  List<ChannelPermissions> permissions;

  /// Emitted on channel update.
  Stream<ChannelUpdateEvent> onUpdate;

  StreamController<ChannelUpdateEvent> _onUpdate;

  // Initializes Guild channel
  void _initialize(Map<String, dynamic> raw, Guild guild) {
    _onUpdate = new StreamController.broadcast();
    onUpdate = _onUpdate.stream;

    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.guild = guild;

    if (raw['parent_id'] != null) {
      this.parentId = new Snowflake(raw['parent_id'] as String);
    }

    this.nsfw = raw['nsfw'] as bool;

    if (raw['permission_overwrites'] != null) {
      permissions = new List();
      raw['permission_overwrites'].forEach((dynamic o) {
        permissions.add(new ChannelPermissions._new(o as Map<String, dynamic>));
      });
    }
  }

  /// Allows to set permissions for channel. [id] param is ID of User or Role
  Future<void> editChannelPermission(PermissionsBuilder perms, Snowflake id,
      {String auditReason: ""}) async {
    await this.client.http.send("PUT", "/channels/${this.id}/permissions/$id",
        body: perms._build()._build(), reason: auditReason);
  }

  /// Deletes permission overwrite for given User or Role id
  Future<void> deleteChannelPermission(Snowflake id,
      {String auditReason: ""}) async {
    await this.client.http.send(
        "POST", "/channels/${this.id}/permissions/$id",
        reason: auditReason);
  }
}
