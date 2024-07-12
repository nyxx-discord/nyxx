import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../mocks/client.dart';

void main() {
  test('CdnAsset', () {
    final asset = CdnAsset(
      client: MockNyxx(),
      base: HttpRoute()
        ..add(HttpRoutePart('hello'))
        ..add(HttpRoutePart('world')),
      hash: 'yup',
    );

    expect(asset.url.toString(), equals('https://cdn.discordapp.com/hello/world/yup.png'));
  });
}
