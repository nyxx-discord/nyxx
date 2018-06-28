part of discord;

/// Embed's footer. Can contain null elements.
class EmbedFooter {
  /// Text inside footer
  String text;

  /// Url of icon whaich is next to text
  String iconUrl;

  /// Proxied url of icon url
  String iconProxyUrl;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  EmbedFooter._new(this.raw) {
    text = raw['text'];
    iconUrl = raw['icon_url'];
    iconProxyUrl = raw['icon_proxy_url'];
  }
}