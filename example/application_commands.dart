import 'dart:io';

import 'package:nyxx/nyxx.dart';

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  // Create a new command named "ping" that takes no arguments.
  // You don't need to create commands every time your client starts - just once
  // when the command is created or updated is sufficient.
  await client.commands.create(
    ApplicationCommandBuilder.chatInput(
      name: 'ping',
      description: 'Ping the bot',
      options: [],
    ),
  );

  // Listen to the interaction stream and handle the ping command.
  client.onApplicationCommandInteraction.listen((event) async {
    if (event.interaction.data.name == 'ping') {
      await event.interaction.respond(MessageBuilder(content: 'Pong!'));
    }
  });
}
