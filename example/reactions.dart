import 'dart:io';

import 'package:nyxx/nyxx.dart';

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  client.onMessageCreate.listen((event) async {
    if (event.message.content.contains('nyxx')) {
      await event.message.react(ReactionBuilder(name: '❤️', id: null));
    }
  });
}
