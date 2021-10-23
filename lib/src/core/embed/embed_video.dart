import 'package:nyxx/src/typedefs.dart';

abstract class IEmbedVideo {
  /// The embed video's URL.
  String? get url;

  /// The embed video's height.
  int? get height;

  /// The embed video's width.
  int? get width;
}

/// Video attached to embed. Can contain null elements.
class EmbedVideo implements IEmbedVideo {
  /// The embed video's URL.
  @override
  late final String? url;

  /// The embed video's height.
  @override
  late final int? height;

  /// The embed video's width.
  @override
  late final int? width;

  /// Creates an instance of [EmbedVideo]
  EmbedVideo(RawApiMap raw) {
    this.url = raw["url"] as String;
    this.height = raw["height"] as int;
    this.width = raw["width"] as int;
  }
}
