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
      flags: MessageFlags.isComponentsV2,
      components: [
        ContainerComponentBuilder(
          accentColor: DiscordColor(9225410),
          components: [
            TextDisplayComponentBuilder(content: "Example components - also check out [discord.builders](https://discord.builders)!"),
            TextDisplayComponentBuilder(content: "\nButtons"),
            ActionRowBuilder(
              components: [
                ButtonBuilder.link(
                  url: Uri.parse("https://pub.dev/packages/nyxx"),
                  label: "Buttons that",
                ),
                ButtonBuilder.primary(
                  label: "you can",
                  customId: "36acfad8d418474084daed1d0d06bef2",
                ),
                ButtonBuilder.secondary(
                  label: "click",
                  customId: "212dc1a845d54912cdff8446cdb3d321",
                ),
              ],
            ),
            TextDisplayComponentBuilder(content: "\nSelect menus"),
            ActionRowBuilder(
              components: [
                SelectMenuBuilder.stringSelect(
                  customId: "99fca274f90a4070beb7086fdf335bfc",
                  minValues: 1,
                  maxValues: 2,
                  options: [
                    SelectMenuOptionBuilder(
                      label: "Test selection",
                      value: "44c530edcff948c5e63764303419e252",
                      description: "test",
                      isDefault: true,
                    ),
                    SelectMenuOptionBuilder(
                      label: "Other selection",
                      value: "c0f60f084fc44e99ec904a89f83ffaf6",
                    ),
                  ],
                ),
              ],
            ),
            TextDisplayComponentBuilder(content: "\nImages"),
            MediaGalleryComponentBuilder(
              items: [
                MediaGalleryItemBuilder(
                  media: UnfurledMediaItemBuilder(url: Uri.parse("https://avatars.githubusercontent.com/u/88039362?s=256")),
                ),
              ],
            ),
          ],
        ),
      ],
    ));
  });
}
