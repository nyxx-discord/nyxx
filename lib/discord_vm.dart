library discord.discord_browser;

import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm.dart'
    show vmTransportPlatform;

/// Configures the client to run in a VM.
void configureDiscordForVM() {
  w_transport.globalTransportPlatform = vmTransportPlatform;
}
