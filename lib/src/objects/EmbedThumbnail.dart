part of discord;

/// A message embed thumbnail.
class EmbedThumbnail extends _BaseObj {
  /// The embed thumbnail's URL.
  String url;

  /// The embed thumbnal's proxy URL.
  String proxyUrl;

  /// The embed thumbnal's height.
  int height;

  /// The embed thumbnal's width.
  int width;

  EmbedThumbnail._new(Client client, Map<String, dynamic> data)
      : super(client) {
    this.url = this._map['url'] = data['url'];
    this.proxyUrl = this._map['proxyUrl'] = data['proxy_url'];
    this.height = this._map['height'] = data['height'];
    this.width = this._map['width'] = data['width'];
    this._map['key'] = this.url;
  }
}
