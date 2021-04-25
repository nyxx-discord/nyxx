## 2.0.0-rc.3
_25.04.2021_

> **Release Candidate 2 for stable version. Requires dart sdk 2.12**

- Support for aliases for Commander (580e55c)
- Fix command aliases (17187c5) @WasserEsser
- Fix command recognition in Commander (7fff136) @WasserEsser

## 1.0.1
_03.09.2020_

* Fix default command handler not being invoked.

## 1.0.0
_24.08.2020_

> **Stable release - breaks with previous versions - this version required Dart 2.9 stable and non-nullable experiment to be enabled to function**

> **`1.0.0` drops support for browser. Nyxx will now run only on VM**

* `dart:mirrors` no longer required to function
* Support for command and command groups
* Allows to run code before and after invoking command. Allows to run code before matching command.
* Fixed and added new functionality to `CommandContext`
    - Support for extracting quoted text, parameters and code blocks
    - Getter for shard that command is executed
* Improved performance and extensibility
