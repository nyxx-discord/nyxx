part of nyxx;

// TODO: NNBD - To consider
/// Video attached to embed. Can contain null elements.
class EmbedVideo implements Downloadable {
  /// The embed video's URL.
  late final String? url;

  /// The embed video's height.
  late final int? height;

  /// The embed video's width.
  late final int? width;

  EmbedVideo._new(Map<String, dynamic> raw) {
    this.url = raw['url'] as String;
    this.height = raw['height'] as int;
    this.width = raw['width'] as int;
  }

  @override
  Future<List<int>?> download() {
    if (url != null) {
      return DownloadUtils.downloadAsBytes(Uri.parse(url));
    }

    return Future.value(null);
  }

  @override
  Future<File> downloadFile(File file) =>
      download().then((data) => file.writeAsBytes(data));

  @override
  String toString() => url ?? "";

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(other) =>
      other is EmbedVideo ? other.url == this.url : false;
}
