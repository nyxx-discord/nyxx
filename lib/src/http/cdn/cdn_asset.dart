import 'dart:typed_data';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/cdn/cdn_request.dart';
import 'package:nyxx/src/http/response.dart';
import 'package:nyxx/src/http/route.dart';

enum CdnFormat {
  png._('png'),
  jpeg._('jpeg'),
  webp._('webp'),
  gif._('gif'),
  lottie._('lottie');

  final String extension;

  const CdnFormat._(this.extension);

  @override
  String toString() => 'CdnFormat($extension)';
}

class CdnAsset {
  final Nyxx client;

  final String hash;

  final HttpRoute base;

  final CdnFormat defaultFormat;

  final bool isAnimated;

  Uri get url => _getRequest(defaultFormat).prepare(client).url;

  CdnAsset({
    required this.client,
    required this.base,
    required this.hash,
    this.defaultFormat = CdnFormat.png,
    bool? isAnimated,
  }) : isAnimated = isAnimated ?? hash.startsWith('a_');

  CdnRequest _getRequest(CdnFormat format) {
    final route = HttpRoute()
      ..parts.addAll(base.parts)
      ..add(HttpRoutePart('$hash.${format.extension}'));

    return CdnRequest(route);
  }

  Future<Uint8List> fetch({CdnFormat? format}) async {
    assert(format != CdnFormat.gif || isAnimated, 'Asset must be animated to fetch as GIF');

    final request = _getRequest(format ?? defaultFormat);

    final response = await client.httpHandler.executeSafe(request);
    return response.body;
  }

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
