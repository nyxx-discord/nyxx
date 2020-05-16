part of nyxx;

/// Embed's footer. Can contain null elements.
class EmbedFooter implements Convertable<EmbedFooterBuilder> {
  /// Text inside footer
  late final String? text;

  /// Url of icon which is next to text
  late final String? iconUrl;

  /// Proxied url of icon url
  late final String? iconProxyUrl;

  EmbedFooter._new(Map<String, dynamic> raw) {
    text = raw['text'] as String?;
    iconUrl = raw['icon_url'] as String?;
    iconProxyUrl = raw['icon_proxy_url'] as String?;
  }

  @override
  String toString() => text ?? "";

  @override
  int get hashCode =>
      text.hashCode * 37 + iconUrl.hashCode * 37 + iconProxyUrl.hashCode * 37;

  @override
  bool operator ==(other) => other is EmbedFooter
      ? other.text == this.text && other.iconUrl == this.iconUrl
      : false;

  @override
  EmbedFooterBuilder toBuilder() {
    return EmbedFooterBuilder()
      ..text = this.text
      ..iconUrl = this.iconUrl;
  }
}
