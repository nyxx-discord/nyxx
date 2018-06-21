# nyxx [![Build Status](https://travis-ci.org/l7ssha/nyxx.svg?branch=master)](https://travis-ci.org/l7ssha/nyxx) [![Pub](https://img.shields.io/pub/v/nyxx.svg)](https://pub.dartlang.org/packages/nyxx)

Simple, robust framework for creating discord bots for Dart.

Fork of [Hackzzila's](https://github.com/Hackzzila) [nyx](https://github.com/Hackzzila/nyx) - extended with new functionality, few bug fixes, applied pending pull requests.

### Features

- *Commands framework* <br>
  Faster way of creating commands for bot. You only have to implement one class, and initialize framework. Everything is done automatically. 
- *Cross Platform* <br>
  nyx works on the command line, browser, mobile, and can be transpiled to JavaScript.
- *Fine Control* <br>
  nyx allows you to control every outgoing HTTP request or websocket messages.
- *Internal Sharding* <br>
  nyx(Nyxx) automatically spawns shards for your bot, but you can override this and spawn a custom number of shards. Internal sharding means that all of your bots servers are managed in one script, no need for communication between shards.

## Documentation and examples

#### [Dartdocs](https://www.dartdocs.org/documentation/nyxx/latest/)

Dartdocs of most recent version of library. It follows `https://pub.dartlang.org/documentation/nyxx/{library-verison}/` to get latest docs version.

#### [Wiki](https://github.com/l7ssha/nyxx/wiki)

Wiki privides examples and descriptions.

## Roadmap
 - Better dartdocs documentation
 - More examples at wiki/more tutorial/Video tutorial 
 - Bigger bot written in nyxx for example
 - Fix `lint` errors from `dartanalyzer`
 - Annotation driver flow for CommandsFramework?
 - Recheck all code and fix styling/small logic bugs
