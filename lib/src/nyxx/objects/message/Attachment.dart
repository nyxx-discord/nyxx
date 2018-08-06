part of nyxx;

/// A message attachment.
class Attachment extends SnowflakeEntity {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The attachment's filename.
  String filename;

  /// The attachment's URL.
  String url;

  /// The attachment's proxy URL.
  String proxyUrl;

  /// The attachment's file size.
  int size;

  /// The attachment's height, if an image.
  int height;

  /// The attachment's width, if an image,
  int width;

  Attachment._new(this.client, this.raw) : super(new Snowflake(raw['id'] as String)) {
    this.filename = raw['filename'] as String;
    this.url = raw['url'] as String;
    this.proxyUrl = raw['proxyUrl'] as String;
    this.size = raw['size'] as int;
    this.height = raw['height'] as int;
    this.width = raw['width'] as int;
  }

  @override
  String toString() => url;
}
