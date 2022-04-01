import 'http_route_param.dart';

class HttpRoutePart {
  final String path;
  final List<HttpRouteParam> params;

  HttpRoutePart(this.path, [this.params = const <HttpRouteParam>[]]);
}