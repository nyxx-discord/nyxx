import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  group('HttpRoute', () {
    test('toString encodes route correctly', () {
      final route = HttpRoute()
        ..add(HttpRoutePart(
          'test',
          [HttpRouteParam('one')],
        ))
        ..add(HttpRoutePart(
          'test-again',
          [HttpRouteParam('two'), HttpRouteParam('three')],
        ));

      expect(route.toString(), equals('/test/one/test-again/two/three'));
    });

    test('rateLimitId is the same for two routes with different minor parameters', () {
      final route1 = HttpRoute()..add(HttpRoutePart('test', [HttpRouteParam('one')]));
      final route2 = HttpRoute()..add(HttpRoutePart('test', [HttpRouteParam('one')]));

      expect(route1.rateLimitId, equals(route2.rateLimitId));
    });

    test('rateLimitId is different for two routes with different major parameters', () {
      final route1 = HttpRoute()..add(HttpRoutePart('test', [HttpRouteParam('one', isMajor: true)]));
      final route2 = HttpRoute()..add(HttpRoutePart('test', [HttpRouteParam('one', isMajor: true)]));

      expect(route1.rateLimitId, equals(route2.rateLimitId));
    });
  });
}
