part of nyxx;

/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info {
  /// The OAuth2 app.
  OAuth2Application app;

  /// The app's bot.
  User bot;

  /// You.
  User me;

  /// Mini guild objects with permissions for every guild you are on.
  Map<Snowflake, OAuth2Guild> guilds;

  OAuth2Info._new(Map<String, dynamic> raw, Nyxx client) {
    this.app =
        OAuth2Application._new(raw['application'] as Map<String, dynamic>);
    this.bot = User._new(raw['bot'] as Map<String, dynamic>, client);
    this.me = User._new(raw['user'] as Map<String, dynamic>, client);

    this.guilds = Map<Snowflake, OAuth2Guild>();
    raw['guilds'].forEach((Map<String, dynamic> v) {
      final OAuth2Guild g = OAuth2Guild._new(v);
      this.guilds[Snowflake(g.id as String)] = g;
    });
    this.guilds;
  }
}
