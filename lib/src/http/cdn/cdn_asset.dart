import 'dart:typed_data';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/cdn/cdn_request.dart';
import 'package:nyxx/src/http/response.dart';
import 'package:nyxx/src/http/route.dart';

/// Available formats for CDN endpoints.
enum CdnFormat {
  /// The PNG format.
  png._('png'),

  /// The JPEG/JPG format.
  jpeg._('jpeg'),

  /// The webp format.
  webp._('webp'),

  /// The GIF format.
  ///
  /// This is only available to endpoints where [CdnAsset.isAnimated] is true.
  gif._('gif'),

  /// The Lottie format.
  ///
  /// This is only available to sticker endpoints where [Sticker.formatType] is [StickerFormatType.lottie].
  lottie._('lottie');

  /// The extension to use on the CDN endpoint for this format.
  final String extension;

  const CdnFormat._(this.extension);

  @override
  String toString() => 'CdnFormat($extension)';
}

/// {@template cdn_asset}
/// An asset, most commonly an image, on Discord's CDN.
/// {@endtemplate}
class CdnAsset {
  /// The client this asset is associated with.
  final Nyxx client;

  /// The hash of the asset.
  final String hash;

  /// The base URL of the asset.
  ///
  /// This is combined with [hash] and [defaultFormat] to obtain [url].
  final HttpRoute base;

  /// The default format for this asset if none is specified.
  final CdnFormat defaultFormat;

  /// Whether this asset is an animated image.
  final bool isAnimated;

  /// The URL at which this asset can be fetched from.
  Uri get url => _getRequest(defaultFormat).prepare(client).url;

  /// {@macro cdn_asset}
  CdnAsset({
    required this.client,
    required this.base,
    required this.hash,
    this.defaultFormat = CdnFormat.png,
    bool? isAnimated,
  }) : isAnimated = isAnimated ?? hash.startsWith('a_');

  CdnRequest _getRequest(CdnFormat format) {
    final route = HttpRoute();

    for (final part in base.parts) {
      route.add(part);
    }
    route.add(HttpRoutePart('$hash.${format.extension}'));

    return CdnRequest(route);
  }

  /// Fetch this asset and return its binary data.
  Future<Uint8List> fetch({CdnFormat? format}) async {
    assert(format != CdnFormat.gif || isAnimated, 'Asset must be animated to fetch as GIF');

    final request = _getRequest(format ?? defaultFormat);

    final response = await client.httpHandler.executeSafe(request);
    return response.body;
  }

  /// Fetch this asset and return a stream of its binary data.
  Stream<List<int>> fetchStreamed({CdnFormat? format}) async* {
    assert(format != CdnFormat.gif || isAnimated, 'Asset must be animated to fetch as GIF');

    final request = _getRequest(format ?? defaultFormat);
    final rawRequest = request.prepare(client);

    final rawResponse = await client.httpHandler.httpClient.send(rawRequest);

    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      throw HttpResponseError.fromResponse(request, rawResponse);
    }

    yield* rawResponse.stream;
  }

  @override
  String toString() => 'CdnAsset($url)';
}
