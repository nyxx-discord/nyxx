import 'package:nyxx/src/core/snowflake_entity.dart';

/// Could be either [IUser], [IMember] or [IWebhook].
/// [IWebhook] will have most of field missing.
abstract class IMessageAuthor implements SnowflakeEntity {
  /// User name
  String get username;

  /// User Discriminator. -1 if webhook
  int get discriminator;

  /// True if bot or webhook
  bool get bot;

  /// User tag: `l7ssha#6712`
  String get tag;

  /// Whether this [IMessageAuthor] is a webhook received by an interaction.
  bool get isInteractionWebhook;

  /// Formatted discriminator with leading zeros if needed
  String get formattedDiscriminator;

  /// The user's avatar, represented as URL.
  /// In case if user does not have avatar, default discord avatar will be returned; [format], [size] and [animated] will no longer affectng this URL.
  /// If [animated] is set as `true`, if available, the url will be a gif, otherwise the [format].
  String avatarUrl({String format = 'webp', int? size, bool animated = true});
}
