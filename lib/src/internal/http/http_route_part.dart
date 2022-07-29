import 'http_route_param.dart';

/// Represents a HTTP route part.
///
/// A HTTP route part is a route fragment (i.e /foo or /bar) followed by 0 or more parameters (i.e a guild or message id) that can change across invocations of
/// the route..
class HttpRoutePart {
  /// The unchanging part of this route part.
  final String path;

  /// The parameters of this route. May change across invocations of this route.
  final List<HttpRouteParam> params;

  HttpRoutePart(this.path, [this.params = const <HttpRouteParam>[]]);
}
