import '../../discord.dart';

/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info {
  /// The OAuth2 app.
  OAuth2Application app;

  /// The app's bot.
  User bot;

  /// You.
  User me;

  /// A list of mini guild objects with permissions for every guild you are on.
  List<OAuth2Guild> guilds = <OAuth2Guild>[];

  /// Constructs a new [OAuth2Info].
  OAuth2Info(Map<String, dynamic> data) {
    this.app = new OAuth2Application(data['application']);
    this.bot = new User(data['bot']);
    this.me = new User(data['user']);

    data['guilds'].forEach((Map<String, dynamic> v) {
      guilds.add(new OAuth2Guild(v));
    });
  }
}
