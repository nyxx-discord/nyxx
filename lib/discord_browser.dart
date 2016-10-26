library discord.discord_browser;

import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/browser.dart' show browserTransportPlatform;

/// Configures the client to run in a browser.
void configureDiscordForBrowser() {
  w_transport.globalTransportPlatform = browserTransportPlatform;
}
