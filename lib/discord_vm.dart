library discord.discord_vm;

import 'dart:io';
import 'discord.dart' as discord;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm.dart' show vmTransportPlatform;

/// Configures the client to run in Dart VM.
void configureDiscordForVM() {
  w_transport.globalTransportPlatform = vmTransportPlatform;
  discord.operatingSystem = Platform.operatingSystem;
  discord.setup = true;
}
