part of nyxx;

// TODO: NNBD - To consider
/// Video attached to embed. Can contain null elements.
class EmbedVideo {
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
  String toString() => url ?? "";

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(other) =>
      other is EmbedVideo ? other.url == this.url : false;
}
