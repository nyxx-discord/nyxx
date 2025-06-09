import 'package:mocktail/mocktail.dart';
import 'package:nock/nock.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';

void main() {
  group('CdnAsset', () {
    setUpAll(() => nock.init());
    tearDownAll(() => nock.cleanAll());

    test('url', () {
      final client = MockNyxx();

      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));

      final asset = CdnAsset(
        client: client,
        base: HttpRoute()
          ..add(HttpRoutePart('hello'))
          ..add(HttpRoutePart('world')),
        hash: 'yup',
      );

      expect(asset.url.toString(), equals('https://cdn.discordapp.com/hello/world/yup.png'));
    });

    test('fetchStreamed handles errors', () async {
      final client = MockNyxx();

      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());
      when(() => client.httpHandler).thenReturn(HttpHandler(client));

      nock('https://cdn.discordapp.com').get('/foo/bar.png').reply(400, '');

      final asset = CdnAsset(
        client: client,
        base: HttpRoute()..add(HttpRoutePart('foo')),
        hash: 'bar',
      );

      expect(asset.fetchStreamed(), emitsError(isA<HttpResponseError>()));
    });
  });
}
