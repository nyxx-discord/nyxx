
import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/application/OAuth2Application.dart';
import 'package:nyxx/src/core/application/OAuth2Guild.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IOAuth2Info {
  /// The OAuth2 app.
  IOAuth2Application get app;

  /// The app's bot.
  IUser get bot;

  /// You.
  IUser get me;

  /// Mini guild objects with permissions for every guild you are on.
  Map<Snowflake, IOAuth2Guild> get guilds;
}


/// Info about a OAuth2 app, bot, user, and possible guilds that that bot can
/// be invited to.
class OAuth2Info {
  /// The OAuth2 app.
  late final OAuth2Application app;

  /// The app's bot.
  late final IUser bot;

  /// You.
  late final IUser me;

  /// Mini guild objects with permissions for every guild you are on.
  late final Map<Snowflake, OAuth2Guild> guilds;

  OAuth2Info._new(RawApiMap raw, INyxx client) {
    this.app = OAuth2Application(raw["application"] as RawApiMap);
    this.bot = User(client, raw["bot"] as RawApiMap);
    this.me = User(client, raw["user"] as RawApiMap);

    this.guilds = <Snowflake, OAuth2Guild>{};
    for (final raw in raw["guilds"]) {
      final guild = OAuth2Guild(raw as RawApiMap);
      this.guilds[Snowflake(guild.id as String)] = guild;
    }
  }
}
