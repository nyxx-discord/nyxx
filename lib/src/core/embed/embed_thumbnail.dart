import 'package:nyxx/src/typedefs.dart';

abstract class IEmbedThumbnail {
  /// The embed thumbnail's URL.
  String? get url;

  /// The embed thumbnal's proxy URL.
  String? get proxyUrl;

  /// The embed thumbnal's height.
  int? get height;

  /// The embed thumbnal's width.
  int? get width;
}

/// A message embed thumbnail.
class EmbedThumbnail implements IEmbedThumbnail {
  /// The embed thumbnail's URL.
  @override
  late final String? url;

  /// The embed thumbnal's proxy URL.
  @override
  late final String? proxyUrl;

  /// The embed thumbnal's height.
  @override
  late final int? height;

  /// The embed thumbnal's width.
  @override
  late final int? width;

  /// Creates an instance of [EmbedThumbnail]
  EmbedThumbnail(RawApiMap raw) {
    url = raw["url"] as String?;
    proxyUrl = raw["proxy_url"] as String?;
    height = raw["height"] as int?;
    width = raw["width"] as int?;
  }
}
