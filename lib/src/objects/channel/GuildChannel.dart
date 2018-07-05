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

  void initialize(Map<String, dynamic> raw) {
    this.name = raw['name'];
    this.position = raw['position'];

    //this.id = raw['id'];
    if (raw.containsKey('parent_id'))
      this.parentId = new Snowflake(raw['parent_id']);

    this.nsfw = raw['nsfw'];
  }
}
