part of nyxx;

/// A message embed thumbnail.
class EmbedThumbnail {
  /// The embed thumbnail's URL.
  String url;

  /// The embed thumbnal's proxy URL.
  String proxyUrl;

  /// The embed thumbnal's height.
  int height;

  /// The embed thumbnal's width.
  int width;

  EmbedThumbnail._new(Map<String, dynamic> raw) {
    this.url = raw['url'] as String;
    this.proxyUrl = raw['proxy_url'] as String;
    this.height = raw['height'] as int;
    this.width = raw['width'] as int;
  }
}
