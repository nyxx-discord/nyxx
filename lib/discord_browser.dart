library discord.discord_browser;

import 'dart:html';
import 'discord.dart' as discord;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/browser.dart' show browserTransportPlatform;

/// Configures the client to run in a browser.
void configureDiscordForBrowser() {
  w_transport.globalTransportPlatform = browserTransportPlatform;
  discord.internals['operatingSystem'] = window.navigator.userAgent;
  discord.internals['browser'] = true;
  discord.internals['setup'] = true;
}
