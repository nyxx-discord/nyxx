# nyxx

[![Discord](https://discordapp.com/api/guilds/846136758470443069/widget.png?style=shield)](https://discord.gg/nyxx)
[![pub](https://img.shields.io/pub/v/nyxx.svg)](https://pub.dev/packages/nyxx)
[![documentation](https://img.shields.io/badge/Documentation-nyxx-yellow.svg)](https://pub.dev/documentation/nyxx/latest/)

A complete, robust and efficient wrapper around Discord's API for bots & applications.

To get started using nyxx, follow our [getting started guide](https://nyxx.l7ssha.xyz/docs/guides/writing_your_first_bot) to write your first bot.

If you're already familiar with Discord's API, here's a quick example to get you started:
```dart
import 'package:nyxx/nyxx.dart';

void main() async {
  final client = await Nyxx.connectGateway('<TOKEN>', GatewayIntents.allUnprivileged);

  final botUser = await client.users.fetchCurrentUser();

  client.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: 'You mentioned me!',
        replyId: event.message.id,
      ));
    }
  });
}
```

## Other nyxx packages

- [nyxx_commands](https://pub.dev/packages/nyxx_commands): A command framework for handling both simple & complex commands.
- [nyxx_pagination](https://pub.dev/packages/nyxx_pagination): Pagination support for nyxx.
- [nyxx_lavalink](https://pub.dev/packages/nyxx_lavalink): Lavalink support for playing audio in voice channels.
- [nyxx_extensions](https://pub.dev/packages/nyxx_extensions): Miscellaneous helpers for common situations when developing bots.

## More examples

- More examples can be found in our GitHub repository [here](https://github.com/nyxx-discord/nyxx/tree/main/example).
- [Running on Dart](https://github.com/nyxx-discord/running_on_dart) is a complete example of a bot written with nyxx.

## Additional documentation & help

The API documentation for the latest stable version can be found on [pub](https://pub.dev/documentation/nyxx).

### [Docs and wiki](https://nyxx.l7ssha.xyz)
Tutorials and wiki articles are hosted here, as well as API documentation for development versions from GitHub.

### [Official nyxx Discord server](https://discord.gg/nyxx)
Our Discord server is where you can get help for any nyxx packages, as well as release announcements and discussions about the library.

### [Discord API docs](https://discord.dev/)
Discord's API documentation details what nyxx implements & provides more detailed explanations of certain topics.

### [Discord API Server](https://discord.gg/discord-api)
The unofficial guild for Discord Bot developers. To get help with nyxx check `#dart_nyxx` channel.

### [Pub.dev docs](https://pub.dev/documentation/nyxx)
The dartdocs page will always have the documentation for the latest release.

## Contributing to Nyxx

Read the [contributing document](https://github.com/nyxx-discord/nyxx/blob/dev/CONTRIBUTING.md)

## Credits 

- Thanks to [Hackzzila's](https://github.com/Hackzzila) for [nyx](https://github.com/Hackzzila/nyx), the original project nyxx was forked from.
