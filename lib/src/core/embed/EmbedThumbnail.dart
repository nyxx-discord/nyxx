part of nyxx;

/// A message embed thumbnail.
class EmbedThumbnail {
  /// The embed thumbnail's URL.
  late final String? url;

  /// The embed thumbnal's proxy URL.
  late final String? proxyUrl;

  /// The embed thumbnal's height.
  late final int? height;

  /// The embed thumbnal's width.
  late final int? width;

  EmbedThumbnail._new(RawApiMap raw) {
    this.url = raw["url"] as String?;
    this.proxyUrl = raw["proxy_url"] as String?;
    this.height = raw["height"] as int?;
    this.width = raw["width"] as int?;
  }

  @override
  String toString() => url ?? "";

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(other) => other is EmbedThumbnail ? other.url == this.url : false;
}
