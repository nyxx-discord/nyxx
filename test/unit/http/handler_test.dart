import 'dart:async';
import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:nock/nock.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../mocks/client.dart';

extension TestRoute on HttpRoute {
  void test() => add(HttpRoutePart('test'));
  void succeed() => add(HttpRoutePart('succeed'));
  void fail() => add(HttpRoutePart('fail'));
}

void main() {
  setUpAll(() {
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  group('HttpHandler', () {
    group('execute', () {
      test('can make basic requests', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        final interceptor = nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test')..reply(200, jsonEncode({'message': 'success'}));

        final route = HttpRoute()..test();
        final request = BasicRequest(route);

        final response = await handler.execute(request);

        expect(interceptor.isDone, isTrue);

        expect(response.statusCode, equals(200));
        expect(response.jsonBody, equals({'message': 'success'}));
      });

      test('returns the correct response type', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        final scope = nock('https://discord.com/api/v${client.apiOptions.apiVersion}');
        final successInterceptor = scope.get('/succeed')..reply(200, jsonEncode({'message': 'success'}));
        final failureInterceptor = scope.get('/fail')..reply(400, jsonEncode({'message': 'failure'}));

        final successRequest = BasicRequest(HttpRoute()..succeed());
        final failureRequest = BasicRequest(HttpRoute()..fail());

        final successResponse = await handler.execute(successRequest);
        final failureResponse = await handler.execute(failureRequest);

        expect(successInterceptor.isDone, isTrue);
        expect(failureInterceptor.isDone, isTrue);

        expect(successResponse, isA<HttpResponseSuccess>());
        expect(failureResponse, isA<HttpResponseError>());
      });
    });

    test('executeSafe throws on request failure', () async {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
      when(() => client.options).thenReturn(RestClientOptions());
      final handler = HttpHandler(client);

      nock('https://discord.com/api/v${client.apiOptions.apiVersion}')
        ..get('/succeed').reply(200, jsonEncode({'message': 'success'}))
        ..get('/fail').reply(400, jsonEncode({'message': 'failure'}));

      final successRequest = BasicRequest(HttpRoute()..succeed());
      final failureRequest = BasicRequest(HttpRoute()..fail());

      expect(handler.executeSafe(successRequest), completion(isA<HttpResponseSuccess>()));
      expect(() => handler.executeSafe(failureRequest), throwsA(isA<HttpResponseError>()));
    });

    group('rate limits', () {
      test('creates buckets from headers', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
          200,
          jsonEncode({'message': 'success'}),
          headers: {
            HttpBucket.xRateLimitBucket: 'testBucketId',
            HttpBucket.xRateLimitLimit: '20',
            HttpBucket.xRateLimitRemaining: '15',
            HttpBucket.xRateLimitReset: '10000',
            HttpBucket.xRateLimitResetAfter: '10.5',
          },
        );

        final request = BasicRequest(HttpRoute()..test());

        await handler.execute(request);

        expect(handler.buckets.length, equals(1));
        expect(handler.buckets.values.single.id, equals('testBucketId'));
      });

      test('hold requests when rate limit might be exceeded', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
          200,
          jsonEncode({'message': 'success'}),
          headers: {
            HttpBucket.xRateLimitBucket: 'testBucketId',
            HttpBucket.xRateLimitLimit: '20',
            HttpBucket.xRateLimitRemaining: '0',
            HttpBucket.xRateLimitReset: '10000',
            HttpBucket.xRateLimitResetAfter: '5',
          },
        );

        final request = BasicRequest(HttpRoute()..test());

        await handler.execute(request);

        // Only add handler after 4 seconds. If the second request runs before this, an error will be thrown.
        Timer(const Duration(seconds: 4), () {
          nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
            200,
            jsonEncode({'message': 'success'}),
            headers: {
              HttpBucket.xRateLimitBucket: 'testBucketId',
              HttpBucket.xRateLimitLimit: '20',
              HttpBucket.xRateLimitRemaining: '19',
              HttpBucket.xRateLimitReset: '10000',
              HttpBucket.xRateLimitResetAfter: '5',
            },
          );
        });

        expect(handler.onRateLimit.where((event) => event.isAnticipated), emits(predicate((_) => true)));
        expect(handler.execute(request), completes);
      });

      test('update on 429 response', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
          429,
          jsonEncode({"message": "You are being rate limited.", "retry_after": 5.0, "global": false}),
          headers: {
            HttpBucket.xRateLimitBucket: 'testBucketId',
            HttpBucket.xRateLimitLimit: '20',
            HttpBucket.xRateLimitRemaining: '19',
            HttpBucket.xRateLimitReset: '10000',
            HttpBucket.xRateLimitResetAfter: '5',
          },
        );

        final request = BasicRequest(HttpRoute()..test());

        Timer(const Duration(seconds: 4), () {
          nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
            200,
            jsonEncode({'message': 'success'}),
            headers: {
              HttpBucket.xRateLimitBucket: 'testBucketId',
              HttpBucket.xRateLimitLimit: '20',
              HttpBucket.xRateLimitRemaining: '19',
              HttpBucket.xRateLimitReset: '10000',
              HttpBucket.xRateLimitResetAfter: '5',
            },
          );
        });

        expect(handler.onRateLimit.where((event) => !event.isAnticipated), emits(predicate((_) => true)));

        await expectLater(
          handler.execute(request),
          completion(
            allOf(
              isA<HttpResponseSuccess>(),
              predicate<HttpResponseSuccess>((response) => response.statusCode == 200),
            ),
          ),
        );

        expect(handler.globalReset, isNull);
      });

      test('handles global rate limit', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
          429,
          jsonEncode({"message": "You are being rate limited.", "retry_after": 5.0, "global": true}),
          headers: {
            HttpBucket.xRateLimitBucket: 'testBucketId',
            HttpBucket.xRateLimitLimit: '20',
            HttpBucket.xRateLimitRemaining: '19',
            HttpBucket.xRateLimitReset: '10000',
            HttpBucket.xRateLimitResetAfter: '5',
          },
        );

        final request = BasicRequest(HttpRoute()..test());

        Timer(const Duration(seconds: 4), () {
          nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
            200,
            jsonEncode({'message': 'success'}),
            headers: {
              HttpBucket.xRateLimitBucket: 'testBucketId',
              HttpBucket.xRateLimitLimit: '20',
              HttpBucket.xRateLimitRemaining: '19',
              HttpBucket.xRateLimitReset: '10000',
              HttpBucket.xRateLimitResetAfter: '5',
            },
          );
        });

        expect(handler.onRateLimit.where((event) => event.isGlobal), emits(predicate((_) => true)));

        await expectLater(
          handler.execute(request),
          completion(
            allOf(
              isA<HttpResponseSuccess>(),
              predicate<HttpResponseSuccess>((response) => response.statusCode == 200),
            ),
          ),
        );

        expect(handler.globalReset, isNot(isNull));
      });

      test('handles batch request rate limits', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'test token'));
        when(() => client.options).thenReturn(RestClientOptions());
        final handler = HttpHandler(client);

        for (final duration in [Duration.zero, Duration(seconds: 4), Duration(seconds: 9)]) {
          Timer(duration, () {
            // Accept 5 requests
            for (int i = 0; i < 5; i++) {
              nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get('/test').reply(
                200,
                jsonEncode({'message': 'success'}),
                headers: {
                  HttpBucket.xRateLimitBucket: 'testBucketId',
                  HttpBucket.xRateLimitLimit: '5',
                  HttpBucket.xRateLimitRemaining: (4 - i).toString(),
                  HttpBucket.xRateLimitReset: '10005',
                  HttpBucket.xRateLimitResetAfter: '5',
                },
              );
            }
          });
        }

        // First 0-duration timer needs to trigger to register the initial handlers
        await Future.delayed(Duration(milliseconds: 1));

        // One request to populate bucket information
        await handler.executeSafe(BasicRequest(HttpRoute()..test(), headers: {'count': 'first'}));

        for (int i = 0; i < 14; i++) {
          handler.executeSafe(BasicRequest(HttpRoute()..test(), headers: {'count': i.toString()}));
        }

        // Test should take 15 seconds (3 batches of 5 second limits) + some small amount of processing time.
        // We need to close the handler so the call to toList below completes.
        Timer(Duration(seconds: 16), () => handler.close());

        final list = await handler.onResponse.where((event) => event.statusCode == 429).toList();

        expect(list, isEmpty);
      });
    });
  });
}
