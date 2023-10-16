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

When submitting a pull request, please, always create a new branch with the following format; `[scope]/name`.
`[scope]` must be the type of changes your PR alter. E.g, when adding a new feature, it must be `feat/`, for a bugfix, `bug/` or `fix/`, etc..

Do not push your changes on the three main branches, it can messes up with rebases.

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
