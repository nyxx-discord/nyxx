import 'package:http/http.dart';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';

class CdnRequest extends HttpRequest {
  CdnRequest(super.route) : super(method: 'GET', authenticated: false, applyGlobalRateLimit: false);

  @override
  BaseRequest prepare(Nyxx client) {
    return Request(method, Uri.https(client.apiOptions.cdnHost, route.path));
  }
}
