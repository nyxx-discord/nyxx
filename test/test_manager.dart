import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:nock/nock.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import 'package:nock/src/interceptor.dart';

import 'mocks/client.dart';
import 'test_endpoint.dart';

class ParsingTest<T, U, V> {
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

  void runWithManager(T manager) {
    final object = parse(manager)(source);
    check(object);
  }
}

class EndpointTest<T, U, V> {
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

  Future<void> runWithManager(T manager) async {
    final entity = await execute(manager);
    check(entity);
  }
}

Future<void> testReadOnlyManager<T extends ManagedSnowflakeEntity<T>, U extends ReadOnlyManager<T>>(
  String name,
  U Function(CacheConfig<T>, NyxxRest) create,
  Pattern baseUrlMatcher, {
  required Map<String, Object?> sampleObject,
  required void Function(T) sampleMatches,
  List<Map<String, Object?>>? additionalSampleObjects,
  List<void Function(T)>? additionalSampleMatchers,
  required List<ParsingTest<U, dynamic, dynamic>>? additionalParsingTests,
  required List<EndpointTest<U, dynamic, dynamic>>? additionalEndpointTests,
  void Function()? extraRun,
  Object? fetchObjectOverride,
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
          parsingTest.runWithManager(manager);
        });
      }
    }

    testEndpoint(
      name: 'fetch',
      baseUrlMatcher,
      response: fetchObjectOverride ?? sampleObject,
      (client) async {
        final manager = create(CacheConfig(), client);

        final entity = await manager.fetch(Snowflake(1));
        sampleMatches(entity);
      },
    );

    test('fetch caches entity', () async {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());
      when(() => client.httpHandler).thenReturn(HttpHandler(client));

      nock('https://discord.com/api/v${client.apiOptions.apiVersion}').get(baseUrlMatcher).reply(200, jsonEncode(fetchObjectOverride ?? sampleObject));

      final manager = create(CacheConfig(), client);
      final entity = await manager.fetch(Snowflake(1));

      expect(manager.cache.containsKey(entity.id), isTrue);
    });

    for (int i = 0; i < (additionalSampleObjects?.length ?? 0); i++) {
      final sample = additionalSampleObjects![i];
      final matcher = additionalSampleMatchers![i];

      testEndpoint(
        name: 'fetch ($i)',
        baseUrlMatcher,
        response: sample,
        (client) async {
          final manager = create(CacheConfig(), client);

          final entity = await manager.fetch(Snowflake(1));
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
            await endpointTest.runWithManager(manager);
          },
        );
      }
    }

    extraRun?.call();
  });
}

Future<void> testManager<T extends WritableSnowflakeEntity<T>, U extends Manager<T>>(
  String name,
  U Function(CacheConfig<T>, NyxxRest) create,
  Pattern baseUrlMatcher,
  Pattern createUrlMatcher, {
  required Map<String, Object?> sampleObject,
  required void Function(T) sampleMatches,
  List<Map<String, Object?>>? additionalSampleObjects,
  List<void Function(T)>? additionalSampleMatchers,
  required List<ParsingTest<U, dynamic, dynamic>>? additionalParsingTests,
  required List<EndpointTest<U, dynamic, dynamic>>? additionalEndpointTests,
  required CreateBuilder<T> createBuilder,
  required UpdateBuilder<T> updateBuilder,
  String createMethod = 'POST',
  Object? fetchObjectOverride,
}) async {
  await testReadOnlyManager<T, U>(
    name,
    create,
    baseUrlMatcher,
    sampleObject: sampleObject,
    sampleMatches: sampleMatches,
    additionalSampleObjects: additionalSampleObjects,
    additionalSampleMatchers: additionalSampleMatchers,
    additionalParsingTests: additionalParsingTests,
    additionalEndpointTests: additionalEndpointTests,
    fetchObjectOverride: fetchObjectOverride,
    extraRun: () {
      testEndpoint(
        name: 'create',
        method: createMethod,
        createUrlMatcher,
        response: sampleObject,
        (client) async {
          final manager = create(CacheConfig(), client);

          final entity = await manager.create(createBuilder);
          sampleMatches(entity);
        },
      );

      test('create caches entity', () async {
        nock.init();

        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
        when(() => client.options).thenReturn(RestClientOptions());
        when(() => client.httpHandler).thenReturn(HttpHandler(client));

        Interceptor(RequestMatcher(
          createMethod,
          UriMatcher('https://discord.com/api/v${client.apiOptions.apiVersion}', createUrlMatcher),
          BodyMatcher((_, __) => true),
        )).reply(200, jsonEncode(sampleObject));

        final manager = create(CacheConfig(), client);
        final entity = await manager.create(createBuilder);

        expect(manager.cache.containsKey(entity.id), isTrue);

        nock.cleanAll();
      });

      testEndpoint(
        name: 'update',
        method: 'PATCH',
        baseUrlMatcher,
        response: sampleObject,
        (client) async {
          final manager = create(CacheConfig(), client);

          final entity = await manager.update(Snowflake(1), updateBuilder);
          sampleMatches(entity);
        },
      );

      test('update caches entity', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
        when(() => client.options).thenReturn(RestClientOptions());
        when(() => client.httpHandler).thenReturn(HttpHandler(client));

        nock('https://discord.com/api/v${client.apiOptions.apiVersion}').patch(baseUrlMatcher, (_) => true).reply(200, jsonEncode(sampleObject));

        final manager = create(CacheConfig(), client);
        final entity = await manager.update(Snowflake(1), updateBuilder);

        expect(manager.cache.containsKey(entity.id), isTrue);
      });

      testEndpoint(
        name: 'delete',
        method: 'DELETE',
        baseUrlMatcher,
        response: null,
        (client) async {
          final manager = create(CacheConfig(), client);

          await manager.delete(Snowflake(1));
        },
      );

      test('delete caches entity', () async {
        final client = MockNyxx();
        when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
        when(() => client.options).thenReturn(RestClientOptions());
        when(() => client.httpHandler).thenReturn(HttpHandler(client));

        nock('https://discord.com/api/v${client.apiOptions.apiVersion}').delete(baseUrlMatcher).reply(200, jsonEncode(sampleObject));

        final manager = create(CacheConfig(), client);
        final entity = manager.parse(sampleObject);
        manager.cache[entity.id] = entity;

        await manager.delete(entity.id);

        await null;

        expect(manager.cache.containsKey(entity.id), isFalse);
      });
    },
  );
}
