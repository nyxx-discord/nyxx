part of nyxx;

/// A message attachment.
class Attachment extends SnowflakeEntity {
  /// The attachment's filename.
  late final String filename;

  /// The attachment's URL.
  late final String url;

  /// The attachment's proxy URL.
  late final String? proxyUrl;

  /// The attachment's file size.
  late final int size;

  /// The attachment's height, if an image.
  late final int? height;

  /// The attachment's width, if an image.
  late final int? width;

  /// whether this attachment is ephemeral
  /// Note: Ephemeral attachments will automatically be removed after a set period of time.
  /// Ephemeral attachments on messages are guaranteed to be available as long as the message itself exists.
  late final bool ephemeral;

  /// Indicates if attachment is spoiler
  bool get isSpoiler => filename.startsWith("SPOILER_");

  Attachment._new(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.filename = raw["filename"] as String;
    this.url = raw["url"] as String;
    this.proxyUrl = raw["proxyUrl"] as String?;
    this.size = raw["size"] as int;

    this.height = raw["height"] as int?;
    this.width = raw["width"] as int?;

    this.ephemeral = raw["ephemeral"] as bool? ?? false;
  }

  @override
  String toString() => url;

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
