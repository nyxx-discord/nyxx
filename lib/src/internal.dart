import 'client.dart';
import 'internal/ws.dart';
import 'internal/http.dart';
import 'internal/util.dart';
import 'internal/eventcontroller.dart';

/// The client's internals.
class InternalClient {
  /// The HTTP manager.
  HTTP http;

  /// The WS manager.
  WS ws;
  
  /// The event controller.
  EventController events;

  /// The utility methods.
  Util util;

  /// Makes a new `InternalClient`
  InternalClient(Client client) {
    client.internal = this;
    this.http = new HTTP(client);
    this.events = new EventController(client);   
    this.util = new Util(); 
    this.ws = new WS(client);
  }
}