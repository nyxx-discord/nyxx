part of discord;

/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info extends _BaseObj {
  /// The OAuth2 app.
  OAuth2Application app;

  /// The app's bot.
  User bot;

  /// You.
  User me;

  /// Mini guild objects with permissions for every guild you are on.
  Collection<Guild> guilds;

  OAuth2Info._new(Client client, Map<String, dynamic> data) : super(client) {
    this.app = this._map['app'] = new OAuth2Application._new(
        this._client, data['application'] as Map<String, dynamic>);
    this.bot = this._map['bot'] =
        new User._new(client, data['bot'] as Map<String, dynamic>);
    this.me = this._map['me'] =
        new User._new(client, data['user'] as Map<String, dynamic>);

    this.guilds = new Collection<Guild>();
    data['guilds'].forEach((Map<String, dynamic> v) {
      final OAuth2Guild g = new OAuth2Guild._new(this._client, v);
      this.guilds.add(g);
    });
    this._map['guild'] = this.guilds;
  }
}
