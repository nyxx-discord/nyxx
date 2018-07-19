/// Nyxx DISCORD API wrapper for Dart
///
/// This module contains commands specific logic that this framework offers.
/// There are 2 implementations of [Commands] handler: [InstanceCommandFramework] and [MirrorsCommandFramework].
/// They are created to achieve same result but has different capabilities. [MirrorsCommandFramework] is more advanced and offers
/// more functionality. In other hand [InstanceCommandFramework] is faster one, because has faster command resolution.
library nyxx.commands;

import "dart:mirrors";
import 'dart:async';
import 'nyxx.dart';

part 'src/commands/CommandExecutionFailEvent.dart';
part 'src/commands/Commands.dart';
part 'src/commands/Subcommand.dart';
part 'src/commands/Command.dart';
part 'src/commands/CooldownCache.dart';
part 'src/commands/InstanceCommandFramework.dart';
part 'src/commands/MirrorsCommandFramework.dart';
