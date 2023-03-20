# Contributing
Nyxx is free and open-source project, and all contributions are welcome and highly appreciated.
However, please conform to the following guidelines when possible.

## Branches

Repo contains few main protected branches:
- `main` - for current stable version. Used for releasing new versions
- `dev` - for changes for next minor or patch version release
- `next` - for changes for next major version release

## Development cycle

All changes should be discussed beforehand either in issue or pull request on github 
or in a discussion in our Discord channel with library regulars or other contributors.

All issues marked with 'help-needed' badge are free to be picked up by any member of the community. 

### Pull Requests

Pull requests should be descriptive about changes that are made. 
If adding new functionality or modifying existing, documentation should be added/modified to reflect changes.

## Coding style

We attempt to conform [Effective Dart Coding Style](https://dart.dev/guides/language/effective-dart/style) where possible.
However, code style rules are not enforcement and code should be readable and easy to maintain.

**One exception to rules above is line limit - we use 160 character line limit instead of 80 chars.**

### Logging
nyxx uses the [`logging`](https://pub.dev/packages/logging) package to do logging, and provides a `Logging` plugin for outputting those logs to the console.

When contributing to the library, please be sure to include logs (if applicable) following these guidelines:
- Use the appropriate logger. The name of the logger helps users filter log messages and quickly identify where a message comes from.
- Use the appropriate level. Log levels are a high-level filter for the verbosity of log output, and knowing what level to send a message at can be difficult, but please try to follow these guidelines:
    - `SHOUT` for messages that indicate that something unexpectedly failed. This is the level equivalent to throwing an exception/error.
    - `SEVERE` for messages that indicate an assertion/sanity check was violated, or for errors not caused by the user.
    - `WARNING` for messages that indicate something *might* fail in the future.
    - `INFO` for messages that report useful information to the user, such as changes in connection state.
    - `CONFIG` for logging values of unchanging fields that might be useful for debugging. These shouldn't be logged repeatedly.
    - `FINE` for messages that report information useful for monitoring what the code is doing.
    - `FINER` for messages bringing additional information to `FINE` level messages. You can think of these as `CONFIG` for `FINE` messages.
    - `FINEST` for messages useful for tracing code execution.

## 6.0.0 rewrite

### Adding HTTP models
The new system for the HTTP API is split into three parts:
- A model, which is a simple Dart class, optionally with methods which forward to a manager
- A manager, which handles calling the API and parsing any responses
- A http handler, which handles rate limiting and sending the request. This is mainly copied from the current version of nyxx.

##### 1. Adding a new model

As an example, let's implement the https://discord.com/developers/docs/resources/user (users) page. The first step in adding a new model is creating the model classes, in `lib/src/models/feature_name/*`:

- If the type is a SnowflakeEntity (an entity with a snowflake ID):
    - A `class PartialXXX extends SnowflakeEntity<XXX> with SnowflakeEntityImpl<XXX>` (ensure the `SnowflakeEntityImpl` import is from `snowflake_entity.dart`)
    - A `class XXX extends PartialXXX`
      Both classes should have a constructor with named parameters for every field, and no other logic.
      The `PartialXXX` class should have a `@override final XXXManager manager` field. We will implement the `XXXManager` next.
- Otherwise, if the type is a custom object:
    - A `class XXX with ToStringHelper` (ensure the `ToStringHelper` is from `to_string_helper.dart`)
      The class should have a constructor with named parameters for every field, and no other logic.
- Otherwise, if the type is an enum:
    - An `enum XXX`
      This enum should have a private constructor, a `factory parse(...)` constructor for parsing the values from the API, and a `toString()` implementation.
- Otherwise, if the type is a bitfield/flags:
    - A `class XXXFlags extends Flags<XXXFlags>` with any number of `static const yyy = Flag<XXXFlags>.fromOffset(...)` flag values.
      This class should also define an `isXXX` for every flag which redirects to the `has(XXX)` for utility and so the printed output shows it correctly.

##### 2. Creating a manager

The next step in the process is creating a manager for the needed type.

For every `SnowflakeEntity` subclass you created, add in `lib/src/http/managers/entity_name.dart`:

- If the API provides methods to create, update & delete the entity type:
    - A `class XXXManager extends Manager<XXX>`
- Otherwise, if the API is readonly/only offers partial edit support:
    - A `class XXXManager extends ReadOnlyManager<XXX>`

Both these classes should have a constructor which has `super.config` and `super.client` fields.

The `[]` operator should be implemented to return an instance of `PartialXXX` with the provided id.
The `parse` method should be implemented to return a complete instance of `XXX` from an API model.
Additional `parseXXX` methods can be added for related types that are not SnowflakeEntities (for example `parseConnection` in `UserManager`)

`fetch`, `create`, `update` and `delete` are self explanatory.
We will implement `CreateBuilder<XXX>` and `UpdateBuilder<XXX>` in a moment.
Note that these methods should update the cache (for now regardless of config, that will be added later).
Note that HTTP requests should be made using `client.httpHandler.executeSafe`.

Additional methods & caches can be added to the manager for other types, for example `fetchCurrentUserConnections` in `UserManager`.
Prefer using `CreateBuilder<XXX>` and `UpdateBuilder<XXX>` instead of a specific builder type. The type argument will guarantee only builders intended for this method are passed.

##### 3. Adding builders

For every type that has a method that needs a `CreateBuilder` or an `UpdateBuilder`, implement the relevant classes in `lib/src/builders/*`.
Logic can be shared between the two classes if needed.

##### 4. Adding utility methods the the data class

Always calling the API through the manager is not the easiest, so we can add utility methods on `PartialXXX` methods which forward to the corresponding manager method.
The `fetch` and `get` utility methods are implemented by `SnowflakeEntity`, so we don't need to worry about those.

##### 5. Adding the manager to the client

To add the manager to the client, edit `lib/src/client_options.dart` (the `RestClientOptions` class), and add a `CacheOptions<XXX>` for each manager.
Next, edit `lib/src/manager_mixin.dart` and add the manager as a `late final` field to the client. Do **not** use a getter, as that will discard the cache every time the manager is accessed.

Things to note:
- Models (ideally the partial class) can have other managers as fields. This allows for nested structures like guilds/messages/channels
- There currently isn't any logging. We can add that later. Since a lot of stuff is consolidated in interfaces/abstract classes now, it should be quite easy.
