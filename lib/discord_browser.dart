library discord.discord_browser;

import 'discord.dart' as discord;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/browser.dart' show browserTransportPlatform;

/// Configures the client to run in a browser.
void configureDiscordForBrowser() {
  w_transport.globalTransportPlatform = browserTransportPlatform;
  discord.operatingSystem = "browser";
  discord.setup = true;
}
