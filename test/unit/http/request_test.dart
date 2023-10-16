import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../mocks/client.dart';

void main() {
  group('BasicRequest', () {
    group('prepare', () {
      test('has correct route', () {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test_token_1234'));

        final request = BasicRequest(HttpRoute()..add(HttpRoutePart('test'))).prepare(client);

        expect(request.url, equals(Uri.parse('https://discord.com/api/v${client.apiOptions.apiVersion}/test')));

        final request2 = BasicRequest(
          HttpRoute()..add(HttpRoutePart('test')),
          queryParameters: {'foo': 'bar'},
        ).prepare(client);

        expect(request2.url, equals(Uri.parse('https://discord.com/api/v${client.apiOptions.apiVersion}/test?foo=bar')));
      });

      test('has correct headers', () {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test_token_1234'));

        final request = BasicRequest(HttpRoute()..add(HttpRoutePart('test'))).prepare(client);

        expect(request.headers['User-Agent'], equals(ApiOptions.defaultUserAgent));
        expect(request.headers['Authorization'], equals(client.apiOptions.authorizationHeader));
        expect(request.headers['Content-Type'], isNot(startsWith(BasicRequest.jsonContentTypeHeader.values.single)));

        final request2 = BasicRequest(
          HttpRoute()..add(HttpRoutePart('test')),
          body: 'test_body',
        ).prepare(client);

        expect(request2.headers['User-Agent'], equals(ApiOptions.defaultUserAgent));
        expect(request2.headers['Authorization'], equals(client.apiOptions.authorizationHeader));
        expect(request2.headers['Content-Type'], startsWith(BasicRequest.jsonContentTypeHeader.values.single));
      });

      test('has correct body', () {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test_token_1234'));

        final request = BasicRequest(
          HttpRoute()..add(HttpRoutePart('test')),
          body: 'test_body',
        ).prepare(client);

        expect(request.body, equals('test_body'));
      });
    });
  });

  group('MultipartRequest', () {
    group('prepare', () {
      test('has correct route', () {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test_token_1234'));

        final request = MultipartRequest(HttpRoute()..add(HttpRoutePart('test'))).prepare(client);

        expect(request.url, equals(Uri.parse('https://discord.com/api/v${client.apiOptions.apiVersion}/test')));
      });

      test('has correct headers', () {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test_token_1234'));

        final request = MultipartRequest(HttpRoute()..add(HttpRoutePart('test'))).prepare(client);

        expect(request.headers['User-Agent'], equals(ApiOptions.defaultUserAgent));
        expect(request.headers['Authorization'], equals(client.apiOptions.authorizationHeader));
      });

      test('has correct payload', () {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test_token_1234'));

        final request = MultipartRequest(
          HttpRoute()..add(HttpRoutePart('test')),
          jsonPayload: 'test_body',
        ).prepare(client);

        expect(request.fields['payload_json'], equals('test_body'));
      });
    });
  });
}
