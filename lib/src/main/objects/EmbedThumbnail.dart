part of discord;

/// A message embed thumbnail.
class EmbedThumbnail {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The embed thumbnail's URL.
  String url;

  /// The embed thumbnal's proxy URL.
  String proxyUrl;

  /// The embed thumbnal's height.
  int height;

  /// The embed thumbnal's width.
  int width;

  EmbedThumbnail._new(this.client, this.raw) {
    this.url = raw['url'];
    this.proxyUrl = raw['proxy_url'];
    this.height = raw['height'];
    this.width = raw['width'];
  }
}
