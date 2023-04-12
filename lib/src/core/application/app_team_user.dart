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

  /// The user's avatar, represented as URL.
  /// In case if user does not have avatar, default discord avatar will be returned; [format], [size] and [animated] will no longer affectng this URL.
  /// If [animated] is set as `true`, if available, the url will be a gif, otherwise the [format] or fallback to "webp".
  String avatarUrl({String format = 'webp', int? size});
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
  String avatarUrl({String format = 'webp', int? size, bool animated = true}) {
    if (avatar == null) {
      return client.cdnHttpEndpoints.defaultAvatar(int.tryParse(discriminator) ?? 0);
    }

    return client.cdnHttpEndpoints.avatar(id, avatar!, format: format, size: size, animated: animated);
  }
}
