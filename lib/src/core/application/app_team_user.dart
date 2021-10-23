import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAppTeamUser implements SnowflakeEntity {
  /// The user's username.
  String get username;

  /// The user's discriminator.
  String get discriminator;

  /// The user's avatar hash.
  String? get avatar;
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

  /// Creates an instance of [AppTeamUser]
  AppTeamUser(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.username = raw["username"] as String;
    this.discriminator = raw["discriminator"] as String;
    this.avatar = raw["avatar"] as String?;
  }
}
