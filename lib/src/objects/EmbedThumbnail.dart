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

  /// Constructs a new [EmbedThumbnail].
  EmbedThumbnail(Map<String, dynamic> data) {
    this.url = data['url'];
    this.proxyUrl = data['proxy_url'];
    this.height = data['height'];
    this.width = data['width'];
  }
}
