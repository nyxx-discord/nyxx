## 2.1.0
__22.10.2021__

- Add pending to member (#224)
- use case-insensitive name comparison in _registerCommandHandlers (#225)

## 2.0.5
_15.10.2021_

- Move to Apache 2 license

## 2.0.4
_09.10_2021_

- Fix #215 - invalid application url was generated with zero permissions (592c4dcc)

## 2.0.3
_04.10.2021_

- Fix #214 - Invalid date in embed timestamp (07d855f1)

## 2.0.2
_03.10.2021_

- fix deserialization of autocomplete interaction

## 2.0.1
_03.10.2021_

 - Fix editMember function declaration

## 2.0.0
_03.10.2021_

Second major stable version of nyxx. Since 1.0 changed a lot - internal are completely rewritten, bots should work faster
and more stable and reliable

 - Implemented message components
 - Reworked rate limits implementation
 - Reworked sharding
 - Reworked http internals. Now all raw api calls are accessible.
 - Rework entity structure allowing more flexibility and partial instantiating
 - Slash commands implementation

## 2.0.0-rc.3
_25.04.2021_

> **Release Candidate 2 for stable version. Requires dart sdk 2.12**

 - Removed `w_transport` and replaced it with `http` package for http module and websockets from `dart:io` (18d0163, 5644937, 9b863a4, 06482f9)
 - Fix replacing embed field. Order of fields is now preserved (f667c2a)
 - Dart2native support (1c6a4f3)
 - Rewrite of internal object structure (ff8953d)
 - Expose raw api call api (f297cc0)
 - Add support for gateway transport compression (fd090dd)
 - Moved to v8 on REST and gateway (423173d)
 - Intents value is now required and added to Nyxx constructor (2b3e002)
 - Added ability to configure cache (163eca9)
 - Implemented stickers (16f2b79)
 - Implemented inline replies (e412ec9)
 - Added raw shard event stream (627f4a0)
 - Fix message reaction events were not triggered when cache misses message (fedbd88)
 - New utils related to slash commands (8e46b71) @HarryET
 - Fixed bug where message with only files cannot be sent (1092624)
 - Fixed setPresence method (fbb9c39) @One-Nub
 - Added missing delete() method to IChannel (131ecc0)
 - Added support for stage channels
 - Added cache options for user 

## 1.0.2
_08.09.2020_

- Fix guild embed channel deserialization
- Fix store and news channel deserialization

## 1.0.1
_29.08.2020_

- Fix voice state cache being not initialized properly.

## 1.0.0
_24.08.2020_

> **Stable release - breaks with previous versions - this version required Dart 2.9 stable and non-nullable experiment to be enabled to function**

> **`1.0.0` drops support for browser. Nyxx will now run only on VM**

 - `nyxx` package contains only basic functionality - everything else is getting own package
   - `main lib package`
        * Fixed errors and exceptions to be more self-explanatory
        * Added new and fixed old examples. Added additional documentation, fixed code to be more idiomatic
        * Logger fixes. User is now able to use their logger implementation. Or disable logging whatsover 
        * New internal http submodule - errors got from discord are always returned to end user. Improved ratelimits and errors hadling
        * Now initial presence can be specified
        * Added support for conneting to voice channel. No audio support by now tho
        * Cache no longer needed for bot to function properly
            - There is now difference between cached and uncached objects
            - Events will provide objects if cache but also raw data received from websocket (etc. snowflakes)
            - Better cache handling with better events performance
        * Implemented missing API features
        * **Added support for sharding. Bot now spawn isolate per shard to handle incoming data**
        * Fixed websocket connectin issues. Now lib should reliably react to websocket errors
        * Added `MemberChunkEvent` to client. Invoked when event is received on websocket.
        * Lib will try to properly close ws connections when process receives SIGTERM OR SIGINT.
        * Added support to shutdown hooks. Code in these hooks will be run before disposing and closed shards and/or client
        * Fixed and moved around docs
        * New internal structure of lib
        * Added extensions for `String` and `int` for more convenient way to convert them to `Snowflake`
        * Added support for gateway intents
        * `Snowflake` objects are now ints
        * Implemented member search endpoints for websocket and API
        * Added missing wrappers for data from discord
        * `==` operator fixes for objects
        
## [0.30.0](https://github.com/l7ssha/nyxx/compare/0.24.0...0.30.0)
_Tue 07.02.2019_

*This version drops support for Dart SDK 1.x; Nyxx now only supports Dart 2.0+ including dev sdk.*

*Changelog can be incomplete - it's hard to track changes across few months*

- **Features added**
  * **SUPPORT FOR DART 2.0+**
  * **ADDED SUPPORT FOR VOICE via Lavalink**
  * **PERMISSIONS OVERHAUL**
    - Proper permissions handling
  * **COMMANDS FRAMEWORK REWRITTEN**
    - Dispatch pipe is completely rewritten. Bot should operate about 2-8x faster
    - Allowed to declare single method commands without using classes
    - Added support for specify custom restrictions to commands handlers
    - Classes now have to be annotated with `Module` instead of `Command`
    - `Remainder` can now called data to `List<String>` or `String`
    - Added `Preprocessor` and `Posprocessor`
    - Removed help system
  * **COMMANDS PARSER**
    - Allows to define simple commands handlers
  * **Nyxx can be now used in browser**
  * Many additions to `Member` and `User` classes
  * Changed internal library structure
  * Implemented Iterable for Channel to query messages
  * Added typing event per channel
  * Using `v7` api endpoint
  * Added support for zlib compressed gateway payload
  * Added endpoints for Guild, Emoji, Role, Member
  * Added utils module
  * Allowed to download attachments. (`Downloadable` interface)
  * Implemented new Discord features (Priority speaker, Slowmode)
  * Added `DiscordColor` class
  * Added `Binder` util
  * Added `Cache`
  * Added `MessageBuilder`
  * Added interfaces `Downloadable`, `Mentionable`, `Debugable`, `Disposable`, `GuildEntity`
- **Bug fixes**
  * **Lowered memory usage**
  * **Websocket fixed**
  * Fixed Emojis comparing
  * Fixed searching in Emojis unicode
  * Code cleanup and style fixes
  * Proper error handling for `CommandsFramework`
  * Gateway fixes
  * Object deserializing fixes
  * Memory and performance improvements
  * Random null exceptions
  * Emojis CDN fixes
  * Few fixes for ratelimitter
- **Changes**
  * **Docs are rewritten**
  * **Faster deserialization**
  * **Embed builders rewritten**
  * Removed autosharding.
  * Every object which has id is now subclass of `SnowflakeEntity`.
  * Snowflakes are default id entities
  * Internal nyxx API changes
  * Cooldown cache rewritten
  * Presence sending fixes
  * Title is not required for EmbedBuilder
  * Removed unnecessary dependencies

## [0.24.0](https://github.com/l7ssha/nyxx/compare/0.23.1...0.24.0)
_Tue 03.08.2018_

- **Changes**
  * nyxx now supports Dart 2.0
  * Added Interactivity module
  * Added few methods to `CommandContext`
  * Rewritten `CooldownCache`

- **Bug fixes**
  * Fixed `Command` help generating error
  * Fixed Emojis equals operator

## [0.23.1](https://github.com/l7ssha/nyxx/compare/0.23.0...0.23.1)
_Tue 31.07.2018_

- **Bug fixes**
  * Fixed `MessageDeleteEvent` deserializing error
  * Fixed checking for channel nsfw for CommandsFramework

## [0.23.0](https://github.com/l7ssha/nyxx/compare/0.22.1...0.23.0)
_Mon 30.07.2018_

- **New features**
  * Support for services - DEPENDENCY INJECTION
  * Support for type parsing
  * Logging support
  * Listener for messages for channel
  * Automatic registering Services and Commands
  * `Remainder` annotation which captures all remaining text
  * Permissions are now **READ/WRITE** - added PermissionsBuilder
  * Checking for topics and if channel is nsfw for commands
- **Bug fixes**
  * Fixed error throwing
  * Text in quotes is one String
  * Fixed StreamControllers to be broadcast
  * Removed unnecessary fields from DMChannel and GroupDMChannel
  * Big performance improvement of CommandFramework
  * Fixed Permissions opcode
  * `delay()` changed to `nextMessage()`
- **Deprecations**
  * Deprecated browser target  
  * Removed MirrorsCommandFramework and InstanceCommandFramework

## [0.22.1](https://github.com/l7ssha/nyxx/compare/0.22.0...0.22.1)
_Wed 11.07.2018_

- **Bug fixes**
  * Fixed bug with sending Emoji. `toString()` now return proper representation ready to send via message
- **New features**
  * Searching in `EmojisUnicode` is now handled by future.
  * toString() in `User`, `Channel`, `Role` now returns mention instead of content, name etc.

## [0.22.0](https://github.com/l7ssha/nyxx/compare/0.21.5...0.22.0)
_Wed 11.07.2018_

- **Bug fixes**
  * Next serialization bug fixes
- **New features**
  * Added support for [audit logs](https://discordapp.com/developers/docs/resources/audit-log)
  * Searching in `EmojisUnicode` based on shortcode
  
## [0.21.5](https://github.com/l7ssha/nyxx/compare/0.21.4...0.21.5)
_Fri 09.07.2018_

- **Bug fixes**
  * Fixed embed serialization
  
## [0.21.4](https://github.com/l7ssha/nyxx/compare/0.21.3...0.21.4)
_Fri 09.07.2018_

- **Bug fixes**
  * Fixed embed serialization
  
  
## [0.21.3](https://github.com/l7ssha/nyxx/compare/0.21.2...0.21.3)
_Fri 08.07.2018_

- **Bug fixes**
  * Fixed embed serialization
- **Added few Docs**


## [0.21.2](https://github.com/l7ssha/nyxx/compare/0.21.1...0.21.2)
_Fri 06.07.2018_

- **Bug fixes**
  * Added overrides
  * Implemented hashCode
  * Fixed return type for `delay()` in Command class


## [0.21.1](https://github.com/l7ssha/nyxx/compare/0.21.0...0.21.1)
_Fri 06.07.2018_

- **Bug fixes**
  * Fixed constructors in MessageChannel and TextChannel


## [0.21.0](https://github.com/l7ssha/nyxx/compare/0.20.0...0.21.0)
_Fri 06.07.2018_

- **New features**
  * Support for sending files, attaching files in embed
  * Added missing gateway events
  * Replaced String ids with `Snowflake` type
- **Bug fixes**
