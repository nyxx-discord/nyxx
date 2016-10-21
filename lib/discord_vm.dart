library discord.discord_vm;

import 'package:w_transport/w_transport_vm.dart' show configureWTransportForVM;

/// Configures the client to run in Dart VM.
void configureDiscordForVM() {
  configureWTransportForVM();
}
