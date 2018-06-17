library discord.vm;

import 'dart:io';
import 'src/internals.dart' as internals;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm_dart.dart' show vmTransportPlatform;

/// Configures the client to run in Dart VM.
void configureDiscordForVM() {
  w_transport.globalTransportPlatform = vmTransportPlatform;
  internals.operatingSystem = Platform.operatingSystem;
  internals.setup = true;
}
