part of nyxx;

/// Author of embed. Can contain null elements.
class EmbedAuthor implements Downloadable, Convertable<EmbedAuthorBuilder> {
  /// Name of embed author
  String name;

  /// Url to embed author
  String url;

  /// Url to author's url
  String iconUrl;

  /// Proxied icon url
  String iconProxyUrl;

  EmbedAuthor._new(Map<String, dynamic> raw) {
    this.name = raw['name'] as String;
    this.url = raw['url'] as String;
    this.iconUrl = raw['icon_url'] as String;
    this.iconProxyUrl = raw['iconProxyUrl'] as String;
  }

  @override
  Future<List<int>> download() => DownloadUtils.downloadAsBytes(Uri.parse(url));

  @override
  String toString() => name;

  @override
  int get hashCode =>
      url.hashCode * 37 + name.hashCode * 37 + iconUrl.hashCode * 37;

  @override
  bool operator ==(other) => other is EmbedAuthor
      ? other.url == this.url &&
          other.name == this.name &&
          other.iconUrl == this.iconUrl
      : false;

  @override
  EmbedAuthorBuilder toBuilder() {
      return EmbedAuthorBuilder()
          ..url = this.url
          ..name = this.name
          ..iconUrl = this.iconUrl;
  }
}
