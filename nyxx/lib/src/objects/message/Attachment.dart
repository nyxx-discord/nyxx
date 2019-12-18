part of nyxx;

/// A message attachment.
class Attachment extends SnowflakeEntity implements Downloadable {
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

  /// The attachment's width, if an image.
  int width;

  /// Indicates if attachment is spoiler
  bool get isSpoiler => filename.startsWith("SPOILER_");

  Attachment._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this.filename = raw['filename'] as String;
    this.url = raw['url'] as String;
    this.proxyUrl = raw['proxyUrl'] as String;
    this.size = raw['size'] as int;
    this.height = raw['height'] as int;
    this.width = raw['width'] as int;
  }

  @override

  /// Download attachment and return it's bytes
  Future<List<int>> download() => DownloadUtils.downloadAsBytes(Uri.parse(url));

  @override
  String toString() => url;

  @override
  bool operator ==(other) => other is Attachment
      ? other.filename == this.filename && other.url == this.url
      : false;

  @override
  int get hashCode => filename.hashCode * 37 + url.hashCode * 37;
}
