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

- **Commands framework** <br>
  Faster way of creating commands for bot. You just  have to implement one class, and initialize framework. Everything is done automatically. 
- **Cross Platform** <br>
  Nyxx works on the command line, browser, mobile.
- **Fine Control** <br>
  Nyxx allows you to control every outgoing HTTP request or websocket messages.
- **Internal Sharding** <br>
  Nyxx automatically spawns shards for your bot, but you can override this and spawn a custom number of shards. Internal sharding means that all of your bots servers are managed in one script, no need for communication between shards.
- **Complete** <br>
  Nyxx supports nearly all DiscordAPI endpoints.

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
Latest docs for newest release.

#### [Dev docs](https://l7ssha.pl/nyxx)
My website has docs for latests commits - You can read about incoming changes

#### [Wiki](https://github.com/l7ssha/nyxx/wiki)
Wiki docs are designed to match latest release.

## Roadmap
 - [ ] Better dartdocs documentation
 - [x] More examples at wiki/more tutorial/Video tutorial 
 - [ ] Bigger bot written in nyxx for example
 - [ ] Fix `lint` errors from `dartanalyzer`
 - [x] Annotation driver flow for CommandsFramework?
 - [x] Recheck all code and fix styling/small logic bugs
 - [ ] Support for Voice connection
