# nyxx.extensions

[![pub](https://img.shields.io/pub/v/nyxx.svg)](https://pub.dartlang.org/packages/nyxx)
[![documentation](https://img.shields.io/badge/Documentation-nyxx-yellow.svg)](https://www.dartdocs.org/documentation/nyxx/latest/)
[![documentation](https://img.shields.io/badge/Documentation-nyxx.commander-yellow.svg)](https://www.dartdocs.org/documentation/nyxx.commander/latest/)
[![documentation](https://img.shields.io/badge/Documentation-nyxx.interactions-yellow.svg)](https://www.dartdocs.org/documentation/nyxx.interactions/latest/)
[![documentation](https://img.shields.io/badge/Documentation-nyxx.extentions-yellow.svg)](https://www.dartdocs.org/documentation/nyxx.extensions/latest/)

Simple, robust framework for creating discord bots for Dart language.

<hr />

### Features

- **Slash commands support** <br>
  Supports and provides easy API for creating and handling slash commands
- **Commands framework included** <br>
  A fast way to create a bot with command support. Implementing the framework is simple - and everything is done automatically.
- **Cross Platform** <br>
  Nyxx works on the command line, in the browser, and on mobile devices.
- **Fine Control** <br>
  Nyxx allows you to control every outgoing HTTP request or WebSocket message.
- **Complete** <br>
  Nyxx supports nearly all Discord API endpoints.


## Quick example

Basic usage:
```dart
void main() {
  final bot = Nyxx("TOKEN", GatewayIntents.allUnprivileged);

  bot.onMessageReceived.listen((event) {
    if (event.message.content == "!ping") {
      (event.message.channel.getOrDownload() as TextChannel).sendMessage(content: "Pong!");
    }
  });
}
```

Slash commands:
```dart
void main() {
  final bot = Nyxx("<%TOKEN%>", GatewayIntents.all);
  final interactions = Interactions(bot);

  interactions
    ..registerHandler("test", "This is test comamnd", [], handler: (event) async {
      await event.acknowledge(showSource: true);
      await event.reply(content: "This is example message result");
    });
}
```

Commands:
```dart
void main() {
  final bot = Nyxx("TOKEN", GatewayIntents.allUnprivileged);

  Commander(bot, prefix: "!!!")
    ..registerCommand("ping", (context, message) => context.reply(content: "Pong!"));
}
```

## More examples

Nyxx examples can be found [here](https://github.com/l7ssha/nyxx/tree/dev/nyxx/example).

Commander examples can be found [here](https://github.com/l7ssha/nyxx/tree/dev/nyxx.commander/example)

Slash commands (interactions) examples can be found [here](https://github.com/l7ssha/nyxx/tree/dev/nyxx.interactions/example)

### Example bots
 - [Running on Dart](https://github.com/l7ssha/running_on_dart)

## Documentation, help and examples

**Dartdoc documentation is hosted on [pub](https://www.dartdocs.org/documentation/nyxx/latest/). 
This wiki just fills gap in docs with more descriptive guides and tutorials.**

#### [Discord API docs](https://discordapp.com/developers/docs/intro)
Discord API documentation features rich descriptions about all topics that nyxx covers.

#### [Discord API Guild](https://discord.gg/discord-api)
The unofficial guild for Discord Bot developers. To get help with nyxx check `#dart_nyxx` channel.

#### [Dartdocs](https://www.dartdocs.org/documentation/nyxx/latest/)
The dartdocs page will always have the documentation for the latest release.

#### [Dev docs](https://nyxx.l7ssha.xyz)
You can read about upcoming changes in the library on my website.

#### [Wiki](https://github.com/l7ssha/nyxx/wiki)
Wiki documentation are designed to match the latest Nyxx release.

## Contributing to Nyxx

Read [contributing document](https://github.com/l7ssha/nyxx/blob/development/CONTRIBUTING.md)

## Credits 

 * [Hackzzila's](https://github.com/Hackzzila) for [nyx](https://github.com/Hackzzila/nyx).
