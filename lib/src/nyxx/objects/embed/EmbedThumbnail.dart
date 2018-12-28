part of nyxx;

/// A message embed thumbnail.
class EmbedThumbnail implements Downloadable {
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

  @override
  Future<List<int>> download() => utils.downloadFile(Uri.parse(url));

  @override
  Future<File> downloadFile(File file) async =>
      file.writeAsBytes(await download());

  @override
  String toString() => url;

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(other) => other is EmbedThumbnail ? other.url == this.url : false;
}
