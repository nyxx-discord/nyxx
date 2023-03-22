import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:nock/nock.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import 'package:nock/src/interceptor.dart';

import 'mocks/client.dart';

Future<void> testEndpoint(Pattern endpointMatcher, Future<void> Function(Nyxx) run, {required Object? response, String? name, String method = 'get'}) async {
  group(name ?? endpointMatcher, () {
    setUpAll(() => nock.init());
    tearDownAll(() => nock.cleanAll());

    test('respects response status', () async {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.httpHandler).thenReturn(HttpHandler(client));

      final interceptor = Interceptor(RequestMatcher(
        method,
        UriMatcher('https://discord.com/api/v${client.apiOptions.apiVersion}', endpointMatcher),
        BodyMatcher((_, __) => true),
      ))
        ..reply(400, jsonEncode({'message': 'Intentional testing error', 'code': -1}));

      await expectLater(() => run(client), throwsA(isA<HttpResponseError>()));

      expect(interceptor.isDone, isTrue, reason: 'endpoint call should call the API');
    });

    test('works', () async {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.httpHandler).thenReturn(HttpHandler(client));

      final interceptor = Interceptor(RequestMatcher(
        method,
        UriMatcher('https://discord.com/api/v${client.apiOptions.apiVersion}', endpointMatcher),
        BodyMatcher((_, __) => true),
      ))
        ..reply(200, jsonEncode(response));

      await run(client);

      expect(interceptor.isDone, isTrue, reason: 'endpoint call should call the API');
    });
  });
}