library discord.discord_vm;

import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm.dart'
    show vmTransportPlatform;

/// Configures the client to run in Dart VM.
void configureDiscordForVM() {
  w_transport.globalTransportPlatform = vmTransportPlatform;
}
