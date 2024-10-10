import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../mocks/handler.dart';
import '../../mocks/request.dart';
import '../../mocks/response.dart';

void main() {
  group('HttpBucket', () {
    group('fromResponse', () {
      test('returns null on invalid rate limit headers', () {
        final response = MockPackageHttpResponse();
        final handler = MockHttpHandler();

        when(() => response.headers).thenReturn({
          'foo': 'bar',
          HttpBucket.xRateLimitBucket: 'testBucketId',
          HttpBucket.xRateLimitRemaining: '15',
        });

        expect(HttpBucket.fromResponse(handler, response), isNull);
      });

      test('parses rate limit headers correctly', () {
        final response = MockPackageHttpResponse();
        final handler = MockHttpHandler();

        when(() => response.headers).thenReturn({
          'foo': 'bar',
          HttpBucket.xRateLimitBucket: 'testBucketId',
          HttpBucket.xRateLimitLimit: '20',
          HttpBucket.xRateLimitRemaining: '15',
          HttpBucket.xRateLimitReset: '10000000',
          HttpBucket.xRateLimitResetAfter: '17.5',
        });

        final bucket = HttpBucket.fromResponse(handler, response);

        expect(bucket, isNotNull);
        expect(bucket?.id, equals('testBucketId'));
        expect(bucket?.remaining, equals(15));

        // We're testing code with timings. Assume that up to 500ms lag could occur between the two calls.
        const expectedDuration = Duration(seconds: 17, milliseconds: 500);
        expect(bucket?.resetAfter.inMilliseconds, closeTo(expectedDuration.inMilliseconds, 500));
        expect(bucket?.resetAt.millisecondsSinceEpoch, closeTo(DateTime.now().add(expectedDuration).millisecondsSinceEpoch, 500));
      });
    });

    test('updates correctly with updateWith', () {
      final bucket = HttpBucket(MockHttpHandler(), id: 'testBucketId', remaining: 100, resetAt: DateTime(2000));
      final response = MockPackageHttpResponse();

      when(() => response.headers).thenReturn({
        HttpBucket.xRateLimitBucket: 'testBucketId',
        HttpBucket.xRateLimitLimit: '20',
        HttpBucket.xRateLimitRemaining: '10',
        HttpBucket.xRateLimitReset: '10000000',
        HttpBucket.xRateLimitResetAfter: '100',
      });

      bucket.updateWith(response);

      expect(bucket.remaining, equals(10));
      expect(bucket.resetAt.millisecondsSinceEpoch, closeTo(DateTime.now().add(const Duration(seconds: 100)).millisecondsSinceEpoch, 500));
    });

    test('contains', () {
      final bucket = HttpBucket(MockHttpHandler(), id: 'testBucketId', remaining: 100, resetAt: DateTime(2000));

      final response = MockPackageHttpResponse();
      when(() => response.headers).thenReturn({HttpBucket.xRateLimitBucket: 'testBucketId'});

      expect(bucket.contains(response), isTrue);

      final response2 = MockPackageHttpResponse();
      when(() => response2.headers).thenReturn({HttpBucket.xRateLimitBucket: 'aDifferentId'});

      expect(bucket.contains(response2), isFalse);
    });

    test('accounts for in-flight requests', () {
      final bucket = HttpBucket(MockHttpHandler(), id: 'testBucketId', remaining: 100, resetAt: DateTime(2000));

      expect(bucket.remaining, equals(100));

      final request1 = MockHttpRequest();
      final request2 = MockHttpRequest();
      final request3 = MockHttpRequest();

      bucket.addInflightRequest(request1);
      expect(bucket.remaining, equals(99));

      bucket.addInflightRequest(request2);
      bucket.addInflightRequest(request3);
      expect(bucket.remaining, equals(97));

      bucket.removeInflightRequest(request1);
      expect(bucket.remaining, equals(98));

      bucket.removeInflightRequest(request3);
      expect(bucket.remaining, equals(99));

      bucket.removeInflightRequest(request2);
      expect(bucket.remaining, equals(100));
    });
  });
}
