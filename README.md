# nyxx [![Build Status](https://travis-ci.org/l7ssha/nyxx.svg?branch=master)](https://travis-ci.org/l7ssha/nyxx)

Simple, robust framework for creating discord bots for Dart. Fork of [Hackzzila's](https://github.com/Hackzzila) [nyx](github.com/Hackzzila/nyx) - extended with new functionality, few bug fixes, applied pending pull requests.

#### Commands framework

Faster way of creating commands for bot. You only have to implement one class, and initialize framework. Everything is done automatically. 

#### Cross Platform

nyx works on the command line, browser, mobile, and can be transpiled to JavaScript.

#### Fine Control

nyx allows you to control every outgoing HTTP request or websocket messages.

#### Internal Sharding

nyx(Nyxx) automatically spawns shards for your bot, but you can override this and spawn a custom number of shards. Internal sharding means that all of your bots servers are managed in one script, no need for communication between shards.

