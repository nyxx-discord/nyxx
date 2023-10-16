import 'dart:io';

import 'package:nyxx/nyxx.dart';

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  client.onMessageCreate.listen((event) async {
    if (!event.message.content.startsWith('!create-channel')) return;

    // We can't create channels outside of a guild.
    if (event.guild == null) return;

    // Fetch the channel & cast it to a GuildChannel so we can get its parentId.
    final channel = await event.message.channel.get() as GuildChannel;

    await event.guild!.createChannel(GuildTextChannelBuilder(
      name: 'test-channel',
      parentId: channel.parentId,
    ));
  });
}
