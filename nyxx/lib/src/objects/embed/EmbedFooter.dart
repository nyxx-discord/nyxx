part of nyxx;

/// Embed's footer. Can contain null elements.
class EmbedFooter implements Downloadable, Convertable<EmbedFooterBuilder> {
  /// Text inside footer
  String text;

  /// Url of icon which is next to text
  String iconUrl;

  /// Proxied url of icon url
  String iconProxyUrl;

  EmbedFooter._new(Map<String, dynamic> raw) {
    text = raw['text'] as String;
    iconUrl = raw['icon_url'] as String;
    iconProxyUrl = raw['icon_proxy_url'] as String;
  }

  @override
  Future<List<int>> download() => DownloadUtils.downloadFile(Uri.parse(iconUrl));

  @override
  Future<File> downloadFile(File file) async =>
      file.writeAsBytes(await download());

  @override
  String toString() => text;

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
