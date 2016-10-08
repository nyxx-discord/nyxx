part of discord;

/// A message attachment.
class Attachment {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

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

  /// Constructs a new [Attachment].
  Attachment(this.client, Map<String, dynamic> data) {
    this.id = data['id'];
    this.filename = this.map['filename'] = data['filename'];
    this.url = this.map['url'] = data['url'];
    this.proxyUrl = this.map['proxyUrl'] = data['proxyUrl'];
    this.size = this.map['size'] = data['size'];
    this.height = this.map['height'] = data['height'];
    this.width = this.map['width'] = data['width'];
    this.createdAt = this.map['createdAt'] = this.client._util.getDate(this.id);
  }
}
