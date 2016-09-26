import '../../discord.dart';

/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info {
  /// The client.
  Client client;

  /// The OAuth2 app.
  OAuth2Application app;

  /// The app's bot.
  User bot;

  /// You.
  User me;

  /// Mini guild objects with permissions for every guild you are on.
  Collection guilds;

  /// Constructs a new [OAuth2Info].
  OAuth2Info(this.client, Map<String, dynamic> data) {
    this.app = new OAuth2Application(data['application']);
    this.bot = new User(client, data['bot']);
    this.me = new User(client, data['user']);

    this.guilds = new Collection();
    data['guilds'].forEach((Map<String, dynamic> v) {
      final OAuth2Guild g = new OAuth2Guild(v);
      this.guilds.map[g.id] = g;
    });
  }
}
