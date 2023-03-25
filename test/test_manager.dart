import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:nock/nock.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:test/test.dart';

import 'mocks/client.dart';
import 'test_endpoint.dart';

class ParsingTest<T extends ReadOnlyManager<dynamic>, U, V> {
  final String name;

  final V source;
  final U Function(V) Function(T) parse;
  final void Function(U) check;

  ParsingTest({
    required this.name,
    required this.source,
    required this.parse,
    required this.check,
  });

  void _runWithManager(T manager) {
    final object = parse(manager)(source);
    check(object);
  }
}

class EndpointTest<T extends ReadOnlyManager<dynamic>, U, V> {
  final String name;

  final String method;
  final Pattern urlMatcher;
  final V source;
  final Future<U> Function(T) execute;
  final void Function(U) check;

  EndpointTest({
    this.method = 'get',
    required this.name,
    required this.source,
    required this.urlMatcher,
    required this.execute,
    required this.check,
  });

  Future<void> _runWithManager(T manager) async {
    final entity = await execute(manager);
    check(entity);
  }
}

Future<void> testReadOnlyManager<T extends SnowflakeEntity<T>, U extends ReadOnlyManager<T>>(
  String name,
  U Function(CacheConfig<T>, NyxxRest) create,
  Pattern baseUrlMatcher, {
  required Map<String, Object?> sampleObject,
  required void Function(T) sampleMatches,
  List<Map<String, Object?>>? additionalSampleObjects,
  List<void Function(T)>? additionalSampleMatchers,
  required List<ParsingTest<U, dynamic, dynamic>>? additionalParsingTests,
  required List<EndpointTest<U, dynamic, dynamic>>? additionalEndpointTests,
}) async {
  assert(
    additionalSampleMatchers?.length == additionalSampleObjects?.length,
    'Unbalanced sample object and matcher count',
  );

  group(name, () {
    test('parse', () {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());
      final config = CacheConfig<T>();

      final manager = create(config, client);

      final object = manager.parse(sampleObject);
      sampleMatches(object);

      for (int i = 0; i < (additionalSampleObjects?.length ?? 0); i++) {
        final sample = additionalSampleObjects![i];
        final matcher = additionalSampleMatchers![i];

        final object = manager.parse(sample);
        matcher(object);
      }
    });

    if (additionalParsingTests != null) {
      for (final parsingTest in additionalParsingTests) {
        test(parsingTest.name, () {
          final client = MockNyxx();
          when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
          when(() => client.options).thenReturn(RestClientOptions());
          final config = CacheConfig<T>();

          final manager = create(config, client);
          parsingTest._runWithManager(manager);
        });
      }
    }

    testEndpoint(
      name: 'fetch',
      baseUrlMatcher,
      response: sampleObject,
      (client) async {
        final manager = create(CacheConfig(), client);

        final entity = await manager.fetch(Snowflake.zero);
        sampleMatches(entity);
      },
    );

    test('fetch caches entity', () async {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());
      when(() => client.httpHandler).thenReturn(HttpHandler(client));

      nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get(baseUrlMatcher).reply(200, jsonEncode(sampleObject));

      final manager = create(CacheConfig(), client);
      final entity = await manager.fetch(Snowflake.zero);

      expect(manager.cache.containsKey(entity.id), isTrue);
    });

    for (int i = 0; i < (additionalSampleObjects?.length ?? 0); i++) {
      final sample = additionalSampleObjects![i];
      final matcher = additionalSampleMatchers![i];

      testEndpoint(
        name: 'fetch',
        baseUrlMatcher,
        response: sample,
        (client) async {
          final manager = create(CacheConfig(), client);

          final entity = await manager.fetch(Snowflake.zero);
          matcher(entity);
        },
      );
    }

    if (additionalEndpointTests != null) {
      for (final endpointTest in additionalEndpointTests) {
        testEndpoint(
          method: endpointTest.method,
          name: endpointTest.name,
          endpointTest.urlMatcher,
          response: endpointTest.source,
          (client) async {
            final manager = create(CacheConfig(), client);
            await endpointTest._runWithManager(manager);
          },
        );
      }
    }
  });
}
