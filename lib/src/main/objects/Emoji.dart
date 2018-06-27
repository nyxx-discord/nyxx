part of discord;

class Emoji {
  /// The [Client] object
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// Emoji guild
  Guild guild;

  /// Snowflake id of emoji
  String id;

  /// Name of emoji
  String name;
  
  /// Roles this emoji is whitelisted to
  List<String> rolesIds;

  /// User that created this emoji
  //User user;

  /// whether this emoji must be wrapped in colons
  bool requireColons;

  /// whether this emoji is managed
  bool managed;

  /// whether this emoji is animated
  bool animated;

  Emoji._new(this.client, this.raw, this.guild) {
    print(this.raw);

    this.id = raw['id'];
    this.name = raw['name'];
    //this.user = new User._new(this.client, raw['user'] as Map<String, dynamic>);
    this.requireColons = raw['require_colons'];
    this.managed = raw['managed'];
    this.animated = raw['animated'];

    if(raw['roles'] != null)
      this.rolesIds = raw['roles'] as List<String>;

    this.guild.emojis[this.id] = this;
  }  
}