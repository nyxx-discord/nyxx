## 6.2.0
__20.03.2024__

- feat: Add support for Group DM endpoints when using an OAuth client.
- feat: Add support for `username` and `avatarUrl` parameters for webhooks.
- feat: Add `Spanish, LATAM` locale.
- bug: Fix events being dropped when plugins had async initialization.
- bug: Return an empty list instead of throwing when fetching the permission overrides of a command that has none.
- feat: Add ratelimits when sending Gateway events.
- bug: Allow any `Flags<Permissions>` in `RoleUpdateBuilder.permissions`.
- bug: Export types that were previously kept private.
- feat: Allow plugins to intercept HTTP requests and Gateway events.
- bug: Fix `MessageManager.bulkDelete` not serializing the request correctly.
- bug: Fix `GuildDeleteEvent`s not being parsed when `unavailable` was not explicitly set.
- bug: Correct serialization of guild builders.
- bug: Correct value of `TriggerType.spam`.
- docs: Hide constructors from documentation.
- bug: Fix parsing role flags in guild templates.
- bug: Fix `isHoisted` attribute in role builders.
- bug: Fix all audit log parameters in `StickerManager`, `EmojiManager` and `WebhookManager.update`
- bug: Fix `interactionsEndpointUrl` being ignored in `ApplicationUpdateBuilder`
- feat: Add more shortcut methods on models.
- feat: Add `enforceNone` to `MessageBuilder`.
- feat: Add missing role tags fields.
- bug: Correct the default `User-Agent` header.
- bug: Don't require OAuth2 identify scope when using `NyxxOauth2`.
- feat: Add field to delete events containing the cached entity before it was deleted.

## 6.1.0
__09.12.2023__

- feat: Add payload to `EntitlementDeleteEvent`.
- feat: Add `flags` field to `Sku`.
- feat: Add support for select menu default values.
- feat: Add `GuildUpdateBuilder.safetyAlertsChannelId`.
- docs: Enable link to source in package documentation.
- feat: Add AutoMod message types.
- bug: Fix `ButtonBuilder` serialization.
- bug: Fix `GuildUpdateBuilder` not being able to unset certain settings.
- bug: Fix incorrect `PermissionOverwriteBuilder` serialization when creating/updating channels.
- bug: Fix `GuildManager.listBans` ignoring the provided parameters.
- bug: Correctly export `Credentials` from `package:oauth2` for OAuth2 support.
- bug: Fix members in message interactions not having their guild set.

## 6.0.3
__26.11.2023__

- bug: Fix incorrect serialization of autocompletion interaction responses (again).
- bug: Try to fix invalid sessions triggered by Gateway reconnects.

## 6.0.2
__16.11.2023__

- bug: Fix incorrect assertions in interaction.respond.
- bug: Fix incorrect serialization of autocompletion interaction responses.

## 6.0.1
__01.11.2023__

- bug: Fix incorrect serialization of CommandOptionBuilder.
- bug: Fix customId missing from ButtonBuilder constructor.
- bug: Fix voice states not being cached correctly.
- bug: Fix incorrect parsing of scheduled events.
- bug: Fix `ephemeral` parameter not working when responding to message component interactions.
- bug: Fix parsing button labels when they are not set.
- bug: Fix incorrect serialization of TextInputBuilder.
- bug: Fix some entities not being cached.
- bug: Fix entities getting "stuck" in cache due to momentary high use.
- feat: Add more places entities can be cached from.

## 6.0.0
__16.10.2023__

- rewrite: The entire library has been rewritten from the ground up. No pre-`6.0.0` code is compatible.
  To explore the rewrite, check out [the API documentation](https://pub.dev/documentation/nyxx) or the [documentation website](https://nyxx.l7ssha.xyz).
  For help migrating, use the [migration tool](https://github.com/abitofevrything/nyxx-migration-script) or join [our Discord server](https://discord.gg/nyxx) for additional help.

#### Changes since 6.0.0-dev.3
- bug: Fix `ModalBuilder` having the incorrect data type.
- feat: Add the new `state` field to `ActivityBuilder`.
- bug: Fix `activities` not being sent in the presence update payload.
- bug: Fix casts when parsing `Snowflake`s triggering errors when using ETF.
- bug: Fix incorrect payload preventing the client from muting/deafening itself.
- bug: Correctly export `NyxxPluginState`.
- feat: Implement all new features since the start of the rewrite (including premium subscriptions).
- bug: Fix incorrect parsing of `MessageUpdateEvent`s.
- feat: Add `logger` to plugins and make `name` inferred from `runtimeType` by default.

## 6.0.0-dev.3
__16.09.2023__

- rewrite: Interaction responses now throw errors instead of using assertions.
- rewrite: Improved plugin interface with support for plugin state and a simpler API.
- feat: Added constructors to most builders with multiple configurations.
- feat: Added support for authenticating via OAuth2.
- feat: Added `HttpHandler.onRateLimit` for tracking client rate limiting.
- feat: Parse emoji in reaction events.
- feat: Allow specifying `stdout` and `stderr` in `Logging`.
- feat: Add `NyxxRest.user` to get the current user.
- feat: `Attachment` now implements `CdnAsset` for easier fetching.
- bug: Fixed emoji in SelectMenuBuilder not being sent correctly.
- bug: Fixed parsing members in interaction data.
- bug: `DiscordColor` did not allow a value of `0xffffff` (white).
- bug: Fixed parsing role mentions as role objects in messages.


## 6.0.0-dev.2
__24.08.2023__

- rewrite: Changed `MessageBuilder.embeds` and `MessageUpdateBuilder.embeds` to use a new `EmbedBuilder` instead of `Embed` objects.
- rewrite: Changed all builders to be mutable.
- rewrite: Implement the interactions & message components API.
- rewrite: `ActivityBuilder` is now exported.
- rewrite: Fixed some typos: `ChannelManager.parseForumChanel` -> `ChannelManager.parseForumChannel` and `chanel` -> `channel` in the docs for `VoiceChannel.videoQualityMode`.
- rewrite: Added wrappers around CDN endpoints and assets.
- feat: Added `Permissions.allPermissions`, the set of permission flags with all permissions.
- feat: Added `HttpHandler.latency`, `HttpHandler.realLatency`, `Gateway.latency` and `Shard.latency` for tracking the client's latency.
- feat: `Flags` now has the `~` and the `^` operators.
- feat: Added `HttpHandler.onRequest` and `HttpHandler.onResponse` streams for tracking HTTP requests and responses.
- bug: Fixed `MessageUpdateEvent`s causing a parsing error.
- bug: Fixed classes creating uncaught async errors when `toString()` was invoked on them.
- bug: Empty caches are no longer stored.
- bug: Fixed stickers causing a parsing error.
- bug: Fixed rate limits not applying correctly when multiple requests were queued.
- bug: Fixed `applyGlobalRatelimit` in `HttpRequest` not doing anything.

## 6.0.0-dev.1
__03.07.2023__

- rewrite: The entire library has been rewritten from the ground up. No pre-`6.0.0-dev.1` code is compatible.
  Join our Discord server for updates concerning the migration path and help upgrading.
  For now, check out the new examples and play around with the rewrite to get a feel for it.

## 5.1.1
__11.08.2023__

- bug: Error on ThreadMemberUpdateEvent due invalid event deserialization

## 5.1.0
__16.06.2023__

- feature: Support the new unique username system with global display names.
- bug: remove the `!` in the mention string as it has been deprecated.

## 5.0.4
__04.06.2023__

- bug: Fix invalid casts

## 5.0.3
__11.04.2023__

- bug: Always initialize guild caches

## 5.0.2
__08.04.2023__

- bug: TextChannelBuilder and VoiceChannel builder had rateLimitPerUser and videoQualityMode swapped (#471)
- documentation: Guild members (#470)

## 5.0.1
__18.03.2023__

- documentation: Channel invites (#448)
- bug: Correctly dispose all resources on bot stop (#451)

## 4.5.1
__19.03.2023__

- bug: Correctly dispose all resources on bot stop (#451)

## 5.0.0
__04.03.2023__

- feature: Add named arguments anywhere we can (#396)
- feature: Make CDN urls more reliable (#373)
- feature: Dispatch raw events (#447)
- feature: Implement missing thread features (#429)
- feature:  Add avatar decorations to cdn endpoints (#410)

## 4.5.0
__18.02.2023__

- feature: New message types (#431)
- feature: Thread members details (#432)
- feature: Implement guild active threads endpoint (#434)
- feature: Implement missing forum features (#433)
- feature: ETF Encoding (#420)
- feature: ETF encoding stability and payload compression (#421)
- feature: Implement @silent messages (#442)
- feature: Implement newly created and member fields in thread create event (#441)
- feature: Add flags property to member (#437)
- feature: Audit log create event (#436)
- bug: hasMore is optional for guild.fetchActiveThreads() (#443)
- bug: Mirror fix #352 to multipart request (#445)
- bug: bug: Fix forum channel available tags deserialization
- bug: Fix update member roles equality (#438)
- documentation: Fix comments and nullability in examples (#416)
- documentation: Add message intent to readme (#428)

## 5.0.0-dev.2
__26.01.2023__

- sync with dev branch (up to 4.5.0-dev.0)

## 4.5.0-dev.0
__26.01.2023__

- feature: New message types (#431)
- feature: Thread members details (#432)
- feature: Implement guild active threads endpoint (#434)
- feature: Implement missing forum features (#433)
- feature: ETF Encoding (#420)
- feature: ETF encoding stability and payload compression (#421)
- documentation: Fix comments and nullability in examples (#416)
- documentation: Add message intent to readme (#428)

## 4.4.1
__22.01.2023__

- hotfix: Fix ratelimit handling

## 4.4.0
__12.12.2022__

- feature: Improve error handling and logging (#403)
- bug: Fix build() for GuildEventBuilder
- bug: Update exports

## 4.4.0-dev.0
__20.11.2022__

- feature: Improve error handling and logging (#403)

## 4.3.0
__19.11.2022__

- feature: Add retry with backoff to network operations (gateway and http) (#395)
- feature: automoderation regexes (#393)
- feature: add support for interaction webhooks (#397)
- feature: Forward `RetryOptions`
- bug: Fixed bug when getting IInviteWithMeta (#398)
- bug: Emit bot start to plugins only when ready
- bug: fix builder not building when editing a guild member (#405)

## 5.0.0-dev.1
__15.11.2022__

- feature: Add named arguments anywhere we can (#396)

This version also includes fixes from 4.2.1

## 4.3.0-dev.1
__15.11.2022__

- feature: add support for interaction webhooks (#397)
- bug: Fixed bug when getting IInviteWithMeta (#398)

This version also includes fixes from 4.2.1

## 4.2.1
__15.11.2022__

- hotfix: fix component deserialization failing when `customId` is `null`

## 4.3.0-dev.0
__14.11.2022__

- feature: Add retry with backoff to network operations (gateway and http) (#395)
- feature: automoderation regexes (#393)
- bug: Emit bot start to plugins only when ready

## 4.2.0
__13.11.2022__

- feature: missing forum channel features (#387)
- feature: Add `activeDeveloper` flag (#388)
- feature: Add support for new select menus components (#380
- feature: Prefer using throw over returning Future.error
- bug: Fix null-assert error on shard disposal; don't reconnect shard after disposing
- bug: Cache user when fetching (#384)
- bug: add message content to client (#389)

## 4.2.0-dev.0
__11.11.2022__

- feature: missing forum channel features (#387)
- bug: Cache user when fetching (#384)

## 4.1.3
__01.11.2022__

- bug: Combine decompressed gateway payloads before parsing them

## 4.1.2
__30.10.2022__

- bug: Correctly emit connected event in `ShardManager`

## 4.1.1
__23.10.2022__

- bug: Fix deserialize the emoji id of the forum tag (#378)

## 4.1.0
__25.09.2022__

- feature: Add `invitesDisabled` feature (#370)
- feature: Add pending for member screening (#371)
- feature: member screening events (#372)
- feature: Cache guild events (#369)
- feature: Refactor internal shard system (#368)
- feature: Event to notify change of connection status (#364)
- feature: feature: auto moderation (#353)
- bug: Fixup shard disconnect event

## 5.0.0-dev.0
__20.09.2022__

- refactor: Make CDN urls more reliable (#373)

## 4.1.0-dev.4
__15.09.2022__

- feature: Add `invitesDisabled` feature (#370)
- feature: Add pending for member screening (#371)
- feature: member screening events (#372)

## 4.1.0-dev.3
__03.09.2022__

- feature: Cache guild events (#369)

## 4.1.0-dev.2
__28.08.2022__

- bug: Fixup shard disconnect event

## 4.1.0-dev.1
__28.08.2022__

- feature: Refactor internal shard system (#368)
- feature: Event to notify change of connection status (#364)

## 4.1.0-dev.0
__20.08.2022__

- feature: feature: auto moderation (#353)

## 4.0.0
__29.07.2022__

- breaking: Fix typo in `IHttpResponseSucess`
- breaking: Remove `threeDayThreadArchive` and `sevenDayThreadArchive` guild features
- breaking: Remove all deprecated members
- bug: Fix ratelimiting
  - breaking: All calls to the API are now made via `IHttpRoute`s instead of `String`s.
  - Construct routes by creating an `IHttpRoute()` and `add`ing `HttpRoutePart`s or by calling the helper methods on the route.
- feature: Move to Gateway & API v10
  - Added the Message Content privileged intent
- feature: Add guild Audit Log options
- feature: Implement forum channels
- feature: Implement guild Welcome Screen & Channel
- feature: Add missing Audit log types
- feature: Implement guild Banners
- feature: Implement partial presences
- feature: Add missing guild properties
- feature: Add missing reaction endpoints
- feature: Handle websocket disconnections
- feature: Implement clean client shutdown
- feature: Add `limitLength` to `MessageBuilder`
- feature: Add paginated bans
- feature: Remove dollar prefix for identify payload (#361)
- bug: Fix mention string, and use a better approach to retrieve everyone role (#360)
- bug: Fix incorrect guild URLs
- bug: Fix incorrect file encoding
- bug: Fix member editing
- bug: Fix serialization issues
- bug: Fix uninitialized fields

## 4.0.0-dev.2
__12.06.2022__

- feature: Add missing emoji endpoints (#346)
- feature: Add `threadName` on `IWebhook#execute()` (#348)
- feature: Implement graceful shutdown (#347)
- feature: Implement forum channels (#332)
- feature: Implement Dynamic Bucket Rate Limits (#316)
- feature: Implement paginated bans (#326)
- feature: Implement missing guild properties
- bug: Fixed disconnecting user from voice
- bug: failed to edit guild members (#328)
- bug: Invalid serialization of query params (#352)
- bug: Fix some serialization bugs (#351)

## 4.0.0-dev.1
__09.05.2022__

- feature: Handle no internet on websocket (#321)
- bug: Remove Error form IHttpResponseError (#324)
  - Fixup field names on IHttpResponseError
  - Fixup IHttpResponseSuccess name
- feature: Move to API v10 (#325)

## 4.0.0-dev.0
__31.03.2022__

- feature: Fix target id property and add guild audit logs options (#307)

## 3.4.2
__22.04.2022__

- bug: Fix setting `channel` to `null` in MemberBuilder causing errors

## 3.4.1
__10.04.2022__

- bug: bugfix: failed to edit guild members (#328)

## 3.4.0
__09.04.2022__

- feature: Add `@bannerUrl()` method (#318)
- feature: Implement paginated bans (#326)

## 3.3.1
__30.03.2022__

- bug: Fix member not being initialized in IMessage (#315)

## 3.3.0
__15.03.2022__

- feature: Guild emoji improvements (#305)
  - Added missing properties on `IBaseGuildEmoji`.
  - Partial emoji can be now resolved to it's full instance with `resolve()` method
  - Author of emoji can be now resolved with `fetchCreator()`
- feature: Allow editing messages to remove content (#313)
- feature: Add previous state to *UpdateEvents (#311)
- bug: fix: initialize name and format values for PartialSticker (#308)
- bug: Make IHttpResponseError subclass Exception (#303)
- bug: Update documentation (#302)

## 3.3.0-dev.1
__05.03.2022__

- feature: Guild emoji improvements (#305)
  - Added missing properties on `IBaseGuildEmoji`. 
  - Partial emoji can be now resolved to it's full instance with `resolve()` method
  - Author of emoji can be now resolved with `fetchCreator()`
- bug: Make IHttpResponseError subclass Exception (#303)
- bug: Update documentation (#302)

## 3.3.0-dev.0
__08.02.2022__

- feature: Implement TextInput component type

## 3.2.7
__08.02.2022__

- bugfix: Remove noop constructor parameters. Deprecate old parameters on INyxxFactory

## 3.2.6
__01.02.2022__

- bugfix: Fix permission serialisation

## 3.2.5
__30.01.2022__

- bugfix: Serialization error with permissions on ChannelBuilder. Fixes #294
- bugfix: Fix MemberBuilder serialization json error

## 3.2.4
__23.01.2022__

- bugfix: Properly serialize member edit payload. Fixes #291
- bugfix: Improve shard searching mechanism. Fixes #290
- bugfix: Fix message deserialization bug with roleMentions. Fixes #289

## 3.2.3
__10.01.2022__

- Fixup invalid formatting of emoji in BaseGuildEmoji.formatForMessage (#286)

## 3.2.2
__08.01.2022__

- Fix message edit behavior (#283)
- Fix `addEmbed` behavior on message builder (#284)

## 3.2.1
__01.01.2022__

- Fixup bug with deserialization of new field on voice guild channel introduced in previous release

## 3.2.0
__31.12.2021__

- Add missing ActivityTypes (#275)
- Fix deserialization of presence update event (#277)
- Implement voice channel region (#278)

## 3.1.1
__29.12.2021__

- Correctly expose `builder` parameter in `IMember#edit`

## 3.1.0
__28.12.2021__

- Implement patches needed for external sharding feature (#266)
- Implement boost progress bar (#266)
- Implement timeouts (#267)
  - deprecation of edit method parameters in favor of `MemberBuilder` class. In next major release all parameters except `builder`
    and `auditReason` will be removed 
- Fix incorrectly initialised onDmReceived and onSelfMention streams (#270)

## 3.0.1
__21.12.2021__

- Fix CliItegration plugin not working with IgnoreExceptions (#256)
- Use logger instead of print (#259)
- Fix typo in file name (#260)
- Nullable close code (#261)
- Missing ActivityBuilder (#262)

## 3.0.0
__19.12.2021__

- Implemented new interface-based entity model.
  > All concrete implementations of entities are now hidden behind interfaces which exports only behavior which is
  > intended for end developer usage. For example: User is now not exported and its interface `IUser` is available for developers.
  > This change shouldn't have impact of end developers.
- Implemented basic plugin system for reusable framework plugins (Currently available plugins: Logging, CliIntegration, IgnoreExceptions)
  > INyxx now implements `IPluginManager` inteface which allows registering plugin via `registerPlugin`. Developers can create their
  > own plugins which can access various hooks inside INyxx instance. For now plugins system allows hooking up to
  > `onRegister`, `onBotStart` and `onBotStop`.
- Improved cache system. Cache abstractions provided by nyxx are now compatible with `MapMixin<Snowflake, T>`
  > `SnowflakeCache` now implements `MapMixin<Snowflake, T>` and is compatibile with Map
- Allowed running bot as REST only. It enables extensions that only require nyxx entities and http capabilities.
  > Internals of nyxx were rewritten to allow running entirely in REST mode without websocket connection.
  > Previously similar behavior was available but wasn't working as intended.
- Implemented ITextVoiceTextChannel.
  > Discords beta feature `chat in voice channels` was implemented in form of `ITextVoiceTextChannel` interface
- Added support for Guild Scheduled Events
- Do not send auth header when it's not needed
- Added support for Dart 2.15
- Fixup message update payload deserialization
- Implement multiple files uploads. Fixes #226
- Implement missing webhook endpoints. Fixes #235
- Implement get thread member endpoint; Fixes #234
- Implement edit thread channel functionality; Fixes #247
- Fix few message update event deserialization bugs
- Fix TODOs and all analyzer issues

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development.

## 3.0.0-dev.2
__02.12.2021__ 

- Fixup message update payload deserialization

## 3.0.0-dev.1
__02.12.2021__

- Implement multiple files uploads. Fixes #226
- Implement missing webhook endpoints. Fixes #235
- Implement get thread member endpoint; Fixes #234
- Implement edit thread channel functionality; Fixes #247
- Fix few message update event deserialization bugs
- Fix TODOs and all analyzer issues

## 3.0.0-dev.0
__24.11.2021__

- Implemented new interface-based entity model. 
  > All concrete implementations of entities are now hidden behind interfaces which exports only behavior which is 
  > intended for end developer usage. For example: User is now not exported and its interface `IUser` is available for developers.
  > This change shouldn't have impact of end developers. 
- Implemented basic plugin system for reusable framework plugins (Currently available plugins: Logging, CliIntegration, IgnoreExceptions)
  > INyxx now implements `IPluginManager` inteface which allows registering plugin via `registerPlugin`. Developers can create their
  > own plugins which can access various hooks inside INyxx instance. For now plugins system allows hooking up to
  > `onRegister`, `onBotStart` and `onBotStop`.
- Improved cache system. Cache abstractions provided by nyxx are now compatible with `MapMixin<Snowflake, T>`
  > `SnowflakeCache` now implements `MapMixin<Snowflake, T>` and is compatibile with Map
- Allowed running bot as REST only. It enables extensions that only require nyxx entities and http capabilities.
  > Internals of nyxx were rewritten to allow running entirely in REST mode without websocket connection.
  > Previously similar behavior was available but wasn't working as intended.
- Implemented ITextVoiceTextChannel.
  > Discords beta feature `chat in voice channels` was implemented in form of `ITextVoiceTextChannel` interface 
- Do not send auth header when it's not needed
- Added support for Dart 2.15

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development. 

## 2.1.1
__02.11.2021__

- Fix #236
- Fix #237

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
