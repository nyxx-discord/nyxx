import 'dart:async';
import 'dart:convert';

import 'package:nyxx/nyxx.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:pinenacl/ed25519.dart';

class HttpInteractions extends NyxxPlugin<NyxxRest> {
  @override
  String get name => runtimeType.toString();

  final String _webhookPath;
  final int _port;
  final String _host;
  final String _publicKey;

  HttpInteractions(this._webhookPath, this._host, this._port, this._publicKey);

  @override
  FutureOr<void> afterConnect(NyxxRest client) async {
    final handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler((shelf.Request request) => _echoRequest(request, client));

    final server = await shelf_io.serve(handler, _host, _port);
    server.autoCompress = true;
  }

  Future<shelf.Response> _echoRequest(shelf.Request request, NyxxRest client) async {
    if (!_webhookPath.startsWith(request.url.toString())) {
      return shelf.Response.badRequest();
    }

    if (request.method != 'POST') {
      return shelf.Response.badRequest();
    }

    final requestBody = await request.readAsString();

    final isRequestValid = await _validateSignature(request.headers['X-Signature-Ed25519']!, request.headers['X-Signature-Timestamp']!, requestBody.trim());
    if (!isRequestValid) {
      return shelf.Response.unauthorized({});
    }

    final body = jsonDecode(requestBody) as Map<String, dynamic>;

    final interaction = client.interactions.parse(body);
    client.onEventController.add(InteractionCreateEvent(interaction: interaction));

    if (interaction.type == InteractionType.ping) {
      print("Responding to ping!");
      print(jsonEncode({"type": 1}));

      return shelf.Response.ok(jsonEncode({"type": 1}));
    }

    return shelf.Response.ok({});
  }

  Future<bool> _validateSignature(String signature, String timestamp, String requestBody) async {
    const encoder = Base16Encoder.instance;

    return VerifyKey(encoder.decode(_publicKey))
        .verify(signature: Signature(encoder.decode(signature)), message: Uint8List.fromList(utf8.encode("$timestamp$requestBody")));
  }
}
