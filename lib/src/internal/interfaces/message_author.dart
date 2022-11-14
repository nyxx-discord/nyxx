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

  /// Whether this [IMessageAuthor] is a webhook received by an interaction.
  bool get isInteractionWebhook;

  /// Formatted discriminator with leading zeros if needed
  String get formattedDiscriminator;

  /// Url to user avatar
  String avatarURL({String format = "webp", int size = 128});
}
