import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/event_controller.dart';
import 'package:nyxx/src/internal/http/http_handler.dart';
import 'package:nyxx/src/internal/http_endpoints.dart';

class NyxxRestMock extends Fake implements INyxxRest {
  @override
  IHttpEndpoints get httpEndpoints => HttpEndpoints(this);

  @override
  HttpHandler get httpHandler => HttpHandler(this);

  @override
  IRestEventController get eventsRest => RestEventController();

  @override
  String get token => "test-token";
}
