import 'package:nyxx/src/core/snowflake_entity.dart';

/// Could be either [User], [Member] or [Webhook].
/// [Webhook] will have most of field missing.
abstract class IMessageAuthor implements SnowflakeEntity {
  /// User name
  String get username;

  /// User Discriminator. -1 if webhook
  int get discriminator;

  /// True if bot or webhook
  bool get bot;

  /// User tag: `l7ssha#6712`
  String get tag;

  /// The user's avatar, represented as URL.
  /// In case if user does not have avatar, default discord avatar will be returned with specified size and png format.
  /// If [animatable] is set as `true`, if available, the url will be a gif, otherwise the [format] or fallback to "webp".
  String avatarUrl({String? format, int? size, bool animatable = false});
}
