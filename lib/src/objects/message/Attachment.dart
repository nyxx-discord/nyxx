part of nyxx;

/// A message attachment.
class Attachment {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The attachment's ID
  String id;

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
    this.id = raw['id'];
    this.filename = raw['filename'];
    this.url = raw['url'];
    this.proxyUrl = raw['proxyUrl'];
    this.size = raw['size'];
    this.height = raw['height'];
    this.width = raw['width'];
    this.createdAt = Util.getDate(this.id);
  }
}
