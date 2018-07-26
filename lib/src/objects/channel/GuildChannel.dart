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

  void initialize(Map<String, dynamic> raw) {
    this.name = raw['name'];
    this.position = raw['position'];

    //this.id = raw['id'];
    if (raw['parent_id'] != null) {
      this.parentId = new Snowflake(raw['parent_id']);
    }

    this.nsfw = raw['nsfw'];

    if(raw['permission_overwrites'] != null) {
      permissions = new List();
      raw['permission_overwrites'].forEach((Map<String, dynamic> o) {
        permissions.add(new ChannelPermissions._new(o));
      });
    }
  }
}
