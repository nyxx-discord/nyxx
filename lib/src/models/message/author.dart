import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// An author of a message.
///
/// Will normally be a [User] or a [WebhookAuthor].
abstract class MessageAuthor {
  /// The ID of this entity.
  Snowflake get id;

  /// The username of this entity.
  String get username;

  /// The avatar hash of this entity.
  String? get avatarHash;

  /// The avatar of this entity.
  CdnAsset? get avatar;
}
