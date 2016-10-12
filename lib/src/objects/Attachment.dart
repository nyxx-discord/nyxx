part of discord;

/// A message attachment.
class Attachment extends _BaseObj {
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

  Attachment._new(Client client, Map<String, dynamic> data) : super(client) {
    this.id = data['id'];
    this.filename = this._map['filename'] = data['filename'];
    this.url = this._map['url'] = data['url'];
    this.proxyUrl = this._map['proxyUrl'] = data['proxyUrl'];
    this.size = this._map['size'] = data['size'];
    this.height = this._map['height'] = data['height'];
    this.width = this._map['width'] = data['width'];
    this.createdAt =
        this._map['createdAt'] = this._client._util.getDate(this.id);
    this._map['key'] = this.id;
  }
}
