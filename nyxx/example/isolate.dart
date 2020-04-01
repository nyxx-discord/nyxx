import 'package:nyxx/nyxx.dart';

import 'package:nyxx/Vm.dart';
import 'dart:isolate';
import 'dart:io';

//TODO: NNBD - Rewrite examples to be more idiomatic

void setupBot(SendPort remotePort) {
  /// Setup communication ports
  var port = ReceivePort();
  var sendPort = port.sendPort;
  remotePort.send(sendPort);

  // Create new bot instance
  Nyxx bot = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessageReceived.listen((MessageReceivedEvent e) {
    if (e.message!.content == "!ping") {
      e.message!.channel.send(content: "Pong!");
    }
  });

  port.listen((msg) async {
    var exChannel =
        bot.channels[Snowflake("355365529369706509")] as TextChannel;
    var m = msg.toString();

    if (m.startsWith("SEND")) {
      await exChannel.send(content: m.split(";").last);
    }
  });
}

// Main function
void main() async {
  /// Create port
  var recPort = ReceivePort();

  /// spawn isolate
  await Isolate.spawn(setupBot, recPort.sendPort);

  var sendport = await recPort.first as SendPort;

  /// Wait for user input
  while (true) {
    stdout.write("Send to channel >> ");
    var msg = stdin.readLineSync();
    sendport.send("SEND;$msg");
    stdout.write("\n");
  }
}
