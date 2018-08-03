part of nyxx;

/// Author of embed. Can contain null elements.
class EmbedAuthor {
  /// Name of embed author
  String name;

  /// Url to embed author
  String url;

  /// Url to author's url
  String iconUrl;

  /// Proxied icon url
  String iconProxyUrl;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  EmbedAuthor._new(this.raw) {
    this.name = raw['name'] as String;
    this.url = raw['url'] as String;
    this.iconUrl = raw['icon_url'] as String;
    this.iconProxyUrl = raw['iconProxyUrl'] as String;
  }
}
