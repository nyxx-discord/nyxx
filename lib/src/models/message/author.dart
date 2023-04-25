import 'package:nyxx/src/models/snowflake.dart';

/// An author of a message.
///
/// Will normally be a [User] or a [Webhook].
abstract class MessageAuthor {
  /// The ID of this entity.
  Snowflake get id;

  /// The username of the entity that sent the message.
  String get username;

  /// The avatar hash of the entity that sent the message.
  String? get avatarHash;
}
