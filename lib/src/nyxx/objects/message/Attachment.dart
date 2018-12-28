part of nyxx;

/// A message attachment.
class Attachment extends SnowflakeEntity {
  /// The attachment's filename.
  String filename;

  /// The attachment's URL.
  String url;

  /// The attachment's proxy URL.
  String proxyUrl;

  /// The attachment's file size.
  int size;

  /// The attachment's height, if an image.
  int height;

  /// The attachment's width, if an image,
  int width;

  Attachment._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this.filename = raw['filename'] as String;
    this.url = raw['url'] as String;
    this.proxyUrl = raw['proxyUrl'] as String;
    this.size = raw['size'] as int;
    this.height = raw['height'] as int;
    this.width = raw['width'] as int;
  }

  /// Download attachment and return it's bytes
  Future<List<int>> download() async => utils.downloadFile(Uri.parse(url));

  /// Download attachment and write contents to [file].
  /// Returns updated [File] instance when completed.
  Future<File> downloadFile(File file) async =>
      file.writeAsBytes(await download());

  @override
  String toString() => url;

  @override
  bool operator ==(other) => other is Attachment ? other.filename == this.filename && other.url == this.url : false;

  @override
  int get hashCode => filename.hashCode * 37 + url.hashCode * 37;
}
