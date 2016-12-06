part of discord;

/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The OAuth2 app.
  OAuth2Application app;

  /// The app's bot.
  User bot;

  /// You.
  User me;

  /// Mini guild objects with permissions for every guild you are on.
  Map<String, OAuth2Guild> guilds;

  OAuth2Info._new(this._client, this.raw) {
    this.app = new OAuth2Application._new(
        this._client, raw['application'] as Map<String, dynamic>);
    this.bot = new User._new(_client, raw['bot'] as Map<String, dynamic>);
    this.me = new User._new(_client, raw['user'] as Map<String, dynamic>);

    this.guilds = new Map<String, OAuth2Guild>();
    raw['guilds'].forEach((Map<String, dynamic> v) {
      final OAuth2Guild g = new OAuth2Guild._new(this._client, v);
      this.guilds[g.id] = g;
    });
    this.guilds;
  }
}
