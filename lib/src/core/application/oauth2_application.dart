import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IOAuth2Application implements SnowflakeEntity {
  /// The app's description.
  String get description;

  /// The app's icon hash.
  String? get icon;

  /// The app's cover hash.
  String? get coverImage;

  /// The app's name.
  String get name;

  /// The app's RPC origins.
  List<String>? get rpcOrigins;

  /// Reference to [INyxx].
  INyxx get client;

  /// Returns url to app's icon.
  String? iconUrl({String? format, int? size});

  /// Returns the cover image url of the app.
  String? coverImageUrl({String? format, int? size});
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

  @override
  late final String? coverImage;

  @override
  final INyxx client;

  /// Creates an instance of [OAuth2Application]
  OAuth2Application(RawApiMap raw, this.client) : super(Snowflake(raw["id"])) {
    description = raw["description"] as String;
    name = raw["name"] as String;

    icon = raw["icon"] as String?;
    rpcOrigins = raw["rpc_origins"] as List<String>?;
    coverImage = raw['cover_image'] as String?;
  }

  /// Returns url to apps icon
  @override
  String? iconUrl({String? format, int? size}) {
    if (icon == null) {
      return null;
    }

    return client.cdnHttpEndpoints.appIcon(id, icon!, format: format, size: size);
  }

  @override
  String? coverImageUrl({String? format, int? size}) {
    if (coverImage == null) {
      return null;
    }

    return client.cdnHttpEndpoints.appIcon(id, coverImage!, format: format, size: size);
  }
}
