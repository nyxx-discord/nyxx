part of nyxx;

/// A message attachment.
class Attachment {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The attachment's ID
  Snowflake id;

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

  /// A timestamp for when the message was created.
  DateTime createdAt;

  Attachment._new(this.client, this.raw) {
    this.id = new Snowflake(raw['id'] as String);
    this.filename = raw['filename'] as String;
    this.url = raw['url'] as String;
    this.proxyUrl = raw['proxyUrl'] as String;
    this.size = raw['size'] as int;
    this.height = raw['height'] as int;
    this.width = raw['width'] as int;
    this.createdAt = id.timestamp;
  }

  String toString() => url;
}
