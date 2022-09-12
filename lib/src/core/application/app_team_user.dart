import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAppTeamUser implements SnowflakeEntity {
  /// Reference to [INyxx].
  INyxx get client;

  /// The user's username.
  String get username;

  /// The user's discriminator.
  String get discriminator;

  /// The user's avatar hash.
  String? get avatar;

  String? avatarUrl({String? format, int? size});
}

/// Represent user in member context
class AppTeamUser extends SnowflakeEntity implements IAppTeamUser {
  /// The user's username.
  @override
  late final String username;

  /// The user's discriminator.
  @override
  late final String discriminator;

  /// The user's avatar hash.
  @override
  late final String? avatar;

  @override
  final INyxx client;

  /// Creates an instance of [AppTeamUser]
  AppTeamUser(RawApiMap raw, this.client) : super(Snowflake(raw["id"])) {
    username = raw["username"] as String;
    discriminator = raw["discriminator"] as String;
    avatar = raw["avatar"] as String?;
  }

  @override
  String? avatarUrl({String? format, int? size}) {
    if (avatar == null) {
      return null;
    }
  }
}
