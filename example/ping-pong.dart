import 'package:nyxx/Vm.dart';
import 'package:nyxx/nyxx.dart';

// Main function
void main() {
  configureNyxxForVM();

  // Create new bot instance
  Nyxx bot = Nyxx("<TOKEN>");

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessageReceived.listen((e) {
    if (e.message.content == "!ping") {
      e.message.channel.send(content: "Pong!");
    }
  });
}
