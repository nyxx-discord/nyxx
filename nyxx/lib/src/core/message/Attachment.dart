import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAttachment implements SnowflakeEntity {
  /// The attachment's filename.
  String get filename;

  /// The attachment's URL.
  String get url;

  /// The attachment's proxy URL.
  String? get proxyUrl;

  /// The attachment's file size.
  int get size;

  /// The attachment's height, if an image.
  int? get height;

  /// The attachment's width, if an image.
  int? get width;

  /// whether this attachment is ephemeral
  /// Note: Ephemeral attachments will automatically be removed after a set period of time.
  /// Ephemeral attachments on messages are guaranteed to be available as long as the message itself exists.
  bool get ephemeral;

  /// Indicates if attachment is spoiler
  bool get isSpoiler;
}

/// A message attachment.
class Attachment extends SnowflakeEntity implements IAttachment {
  /// The attachment's filename.
  @override
  late final String filename;

  /// The attachment's URL.
  @override
  late final String url;

  /// The attachment's proxy URL.
  @override
  late final String? proxyUrl;

  /// The attachment's file size.
  @override
  late final int size;

  /// The attachment's height, if an image.
  @override
  late final int? height;

  /// The attachment's width, if an image.
  @override
  late final int? width;

  /// whether this attachment is ephemeral
  /// Note: Ephemeral attachments will automatically be removed after a set period of time.
  /// Ephemeral attachments on messages are guaranteed to be available as long as the message itself exists.
  @override
  late final bool ephemeral;

  /// Indicates if attachment is spoiler
  @override
  bool get isSpoiler => filename.startsWith("SPOILER_");

  /// Creates an instance of [Attachment]
  Attachment(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.filename = raw["filename"] as String;
    this.url = raw["url"] as String;
    this.proxyUrl = raw["proxyUrl"] as String?;
    this.size = raw["size"] as int;

    this.height = raw["height"] as int?;
    this.width = raw["width"] as int?;

    this.ephemeral = raw["ephemeral"] as bool? ?? false;
  }

  @override
  bool operator ==(other) {
    if (other is Attachment) {
      return other.id == this.id;
    }

    if (other is Snowflake) {
      return other == this.id;
    }

    return false;
  }

  @override
  int get hashCode => this.id.hashCode;
}
