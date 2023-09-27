import 'dart:async';
import 'dart:convert';

import 'package:nyxx/nyxx.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

class HttpInteractions extends NyxxPlugin<NyxxRest> {
  @override
  String get name => runtimeType.toString();

  final String _webhookPath;
  final int _port;
  final String _host;

  HttpInteractions(this._webhookPath, this._host, this._port);

  @override
  FutureOr<void> afterConnect(NyxxRest client) async {
    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler((shelf.Request request) => _echoRequest(request, client));

    var server = await shelf_io.serve(handler, _host, _port);
    server.autoCompress = true;
  }

  Future<shelf.Response> _echoRequest(shelf.Request request, NyxxRest client) async {
    if (request.method != 'POST') {
      return shelf.Response.badRequest();
    }

    final body = jsonDecode(
      await request.readAsString()
    ) as Map<String, dynamic>;

    final interaction = client.interactions.parse(body);

    client.onEventController.add(
        InteractionCreateEvent()
    )

    return shelf.Response.badRequest();
  }
}
