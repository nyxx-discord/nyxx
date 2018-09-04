<div align="center">
<br />
<p> <img width="600" src="https://l7ssha.pl/nyxx0.png" />
<br />

[![Build Status](https://travis-ci.org/l7ssha/nyxx.svg?branch=master)](https://travis-ci.org/l7ssha/nyxx)
[![Pub](https://img.shields.io/pub/v/nyxx.svg)](https://pub.dartlang.org/packages/nyxx)
[![documentation](https://img.shields.io/badge/Documentation-nyxx-yellow.svg)](https://www.dartdocs.org/documentation/nyxx/latest/)

Simple, robust framework for creating discord bots for Dart. <br />
Fork of [Hackzzila's](https://github.com/Hackzzila) [nyx](https://github.com/Hackzzila/nyx) - extended with new functionality, few bug fixes, applied pending pull requests.

<hr />

</div>

### Stable release

`nyxx 1.0.0` is first stable release. It uses Dart 2.0 stable and has many rewritten and improved features.

### Features

- **Commands framework included** <br>
  A fast way to create a bot with command support. Implementing the framework is simple - and everything is done automatically.
- **Cross Platform** <br>
  Nyxx works on the command line, in the browser, and on mobile devices.
- **Fine Control** <br>
  Nyxx allows you to control every outgoing HTTP request or WebSocket message.
- **Internal Sharding** <br>
  Nyxx automatically spawns shards for your bot, but you can override this and spawn a custom number of shards. Internal sharding means that all of your bots shards are managed in one script, and there is no need for communication between shards.
- **Complete** <br>
  Nyxx supports nearly all Discord API endpoints.

### Sample

``` dart
void main() {
  discord.Client bot =
      new discord.Client(Platform.environment['DISCORD_TOKEN']);

  bot.onReady.listen((discord.ReadyEvent e) {
    print("Ready!");
  });

  bot.onMessage.listen((discord.MessageEvent e) {
    if (e.message.content == "!ping") {
      e.message.channel.sendMessage(content: "Pong!");
    }
  });
}
```

## Documentation and examples

#### [Dartdocs](https://www.dartdocs.org/documentation/nyxx/latest/)
The dartdocs page will always have the documentation for the latest release.

#### [Dev docs](https://l7ssha.pl/nyxx)
You can read about upcoming changes to the library on my website.

#### [Wiki](https://github.com/l7ssha/nyxx/wiki)
Wiki documentation are designed to match the latest Nyxx release.