import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IOAuth2Application implements SnowflakeEntity {
  /// The app's description.
  String get description;

  /// The app's icon hash.
  String? get icon;

  /// The app's name.
  String get name;

  /// The app's RPC origins.
  List<String>? get rpcOrigins;

  /// Returns url to apps icon
  String? iconUrl({String format = "png", int size = 512});
}

/// An OAuth2 application.
class OAuth2Application extends SnowflakeEntity implements IOAuth2Application {
  /// The app's description.
  @override
  late final String description;

  /// The app's icon hash.
  @override
  late final String? icon;

  /// The app's name.
  @override
  late final String name;

  /// The app's RPC origins.
  @override
  late final List<String>? rpcOrigins;

  /// Creates an instance of [OAuth2Application]
  OAuth2Application(RawApiMap raw) : super(Snowflake(raw["id"])) {
    description = raw["description"] as String;
    name = raw["name"] as String;

    icon = raw["icon"] as String?;
    rpcOrigins = raw["rpcOrigins"] as List<String>?;
  }

  /// Returns url to apps icon
  @override
  String? iconUrl({String format = "png", int size = 512}) {
    if (icon != null) {
      return "https://cdn.discordapp.com/app-icons/$id/$icon.$format?size=$size";
    }

    return null;
  }
}
