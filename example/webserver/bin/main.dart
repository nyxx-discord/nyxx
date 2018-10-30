import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'dart:isolate';
import 'dart:io';

void setupBot(SendPort remotePort) {
  /// Setup communication ports
  var port = ReceivePort();
  var sendPort = port.sendPort;
  remotePort.send(sendPort);

  configureNyxxForVM();

  // Create new bot instance
  Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  client.onReady.listen((ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  client.onMessage.listen((MessageEvent e) {
    remotePort.send("${client.shards.length};${client.guilds.count};${client.uptime.inSeconds}");

    if (e.message.content == "oofping") {
      e.message.channel.send(content: "Pong!");
    }
  });
}

int count = 1;

int curShard = 0;
int curGuild = 0;
int curUp = 1;

// Main function
void main() async {

  /// Create port
  var recPort = ReceivePort();

  /// spawn isolate
  await Isolate.spawn(setupBot, recPort.sendPort);

  recPort.listen((d) {
    if(d is String) {
      var spl = d.split(';');
      curShard = int.parse(spl.first);
      curGuild = int.parse(spl[1]);
      curUp = int.parse(spl.last);
      count++;
    }
  });

  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  io.serve(handler, 'localhost', 9098).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

}

shelf.Response _echoRequest(shelf.Request request) {
  return new shelf.Response.ok('<html>'
      '<body>'
      '<p>Number of shards: ${curShard} </p>'
      '<p>Number of guild connected: ${curGuild}</p>'
      '<p>Messages per second: ${count / curUp}</p>'
      '</body>'
      '</html>', headers: {"Content-Type": "text/html"});
}