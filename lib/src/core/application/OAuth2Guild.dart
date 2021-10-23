import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/application/OAuth2Info.dart';
import 'package:nyxx/src/core/permissions/Permissions.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IOAuth2Guild implements SnowflakeEntity {
  /// The permissions you have on that guild.
  IPermissions get permissions;

  /// The guild's icon hash.
  String get icon;

  /// The guild's name
  String get name;

  /// Returns url to guilds icon
  String? iconUrl({String format = "png", int size = 512});
}

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild extends SnowflakeEntity implements IOAuth2Guild {
  /// The permissions you have on that guild.
  @override
  late final IPermissions permissions;

  /// The guild's icon hash.
  @override
  late final String icon;

  /// The guild's name
  @override
  late final String name;

  /// Creates an instance of [OAuth2Guild]
  OAuth2Guild(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.permissions = Permissions(raw["permissions"] as int);
    this.icon = raw["icon"] as String;
    this.name = raw["name"] as String;
  }

  /// Returns url to guilds icon
  @override
  String? iconUrl({String format = "png", int size = 512}) =>
    "https://cdn.discordapp.com/icons/${this.id.toString()}/$icon.$format?size=$size";
}
