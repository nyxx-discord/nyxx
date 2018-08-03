part of nyxx;

abstract class GuildChannel {
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

  String _id;
  Client _client;

  void initialize(Map<String, dynamic> raw, Client client, Guild guild) {
    this._client = client;
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.guild = guild;

    this._id = raw['id'] as String;
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
  Future<Null> editChannelPermission(PermissionsBuilder perms, Snowflake id,
      {String auditReason: ""}) async {
    await this._client.http.send("PUT", "/channels/${this._id}/permissions/$id",
        body: perms._build()._build(), reason: auditReason);
  }

  /// Deletes permission overwrite for given User or Role id
  Future<Null> deleteChannelPermission(Snowflake id,
      {String auditReason: ""}) async {
    await this._client.http.send(
        "POST", "/channels/${this._id}/permissions/$id",
        reason: auditReason);
  }
}
