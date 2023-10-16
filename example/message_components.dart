import 'dart:io';

import 'package:nyxx/nyxx.dart';

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  client.onMessageCreate.listen((event) async {
    if (!event.message.content.startsWith('!component')) return;

    await event.message.channel.sendMessage(MessageBuilder(
      content: 'Here are some components for you to play with!',
      components: [
        ActionRowBuilder(components: [
          ButtonBuilder(
            label: 'Visit nyxx on pub.dev',
            style: ButtonStyle.link,
            url: Uri.https('pub.dev', '/packages/nyxx'),
          ),
          ButtonBuilder(
            label: 'A primary button',
            style: ButtonStyle.primary,
            customId: 'primary_button',
          ),
          ButtonBuilder(
            label: 'A secondary button',
            style: ButtonStyle.secondary,
            customId: 'secondary_button',
          ),
        ]),
        ActionRowBuilder(components: [
          SelectMenuBuilder(
            type: MessageComponentType.stringSelect,
            customId: 'a_custom_id',
            options: [
              SelectMenuOptionBuilder(label: 'Option 1', value: 'option_1'),
              SelectMenuOptionBuilder(label: 'Option 2', value: 'option_2'),
              SelectMenuOptionBuilder(label: 'Option 3', value: 'option_3'),
            ],
          ),
        ]),
      ],
    ));
  });
}
