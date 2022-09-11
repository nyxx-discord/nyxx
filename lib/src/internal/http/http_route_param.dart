/// Represents a HTTP route parameter.
///
/// A HTTP route parameter is a URL fragment that contains data specific to an invocation of a route (i.e a guild or message id).
///
/// In the Discord documentation, these are the parts of URLs {enclosed in curly braces}.
class HttpRouteParam {
  /// The value of this parameter.
  final String param;

  /// Whether this parameter is a major parameter.
  ///
  /// Major parameters influence Discord's rate limiting. Requests with different major parameters will go into separate buckets for rate limiting, whereas
  /// routes with different minor parameters will use the same bucket.
  final bool isMajor;

  HttpRouteParam(this.param, {this.isMajor = false});
}

/// Represents a HTTP CDN route.
///
/// These routes does not complain to global/bucket rate-limits as they're static.
class CdnHttpRouteParam implements HttpRouteParam {
  /// The value of this parameter.
  @override
  final String param;

  CdnHttpRouteParam(this.param);

  @override
  bool get isMajor => throw UnimplementedError();
}
