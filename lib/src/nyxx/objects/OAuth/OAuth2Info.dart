part of nyxx;

/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info {
  /// The [Nyxx] object.
  Nyxx client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The OAuth2 app.
  OAuth2Application app;

  /// The app's bot.
  User bot;

  /// You.
  User me;

  /// Mini guild objects with permissions for every guild you are on.
  Map<Snowflake, OAuth2Guild> guilds;

  OAuth2Info._new(this.client, this.raw) {
    this.app = OAuth2Application._new(
        this.client, raw['application'] as Map<String, dynamic>);
    this.bot = User._new(client, raw['bot'] as Map<String, dynamic>);
    this.me = User._new(client, raw['user'] as Map<String, dynamic>);

    this.guilds = Map<Snowflake, OAuth2Guild>();
    raw['guilds'].forEach((Map<String, dynamic> v) {
      final OAuth2Guild g = OAuth2Guild._new(this.client, v);
      this.guilds[Snowflake(g.id as String)] = g;
    });
    this.guilds;
  }
}
