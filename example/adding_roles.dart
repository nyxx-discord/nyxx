import 'dart:io';

import 'package:nyxx/nyxx.dart';

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  client.onMessageCreate.listen((event) async {
    if (!event.message.content.startsWith('!new-role')) return;
    if (event.guild == null) return;

    final role = await event.guild!.roles.create(RoleBuilder(
      name: 'Test role',
      color: DiscordColor.fromRgb(66, 165, 245),
    ));

    await event.member!.addRole(role.id);
  });
}
