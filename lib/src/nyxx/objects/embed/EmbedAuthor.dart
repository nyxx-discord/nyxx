part of nyxx;

/// Author of embed. Can contain null elements.
class EmbedAuthor implements Downloadable {
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
  Future<List<int>> download() => utils.downloadFile(Uri.parse(url));

  @override
  Future<File> downloadFile(File file) async =>
      file.writeAsBytes(await download());
}
