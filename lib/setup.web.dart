library nyxx.setup;

import 'dart:html';
import 'src/internals.dart' as internals;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/browser.dart' show browserTransportPlatform;

/// Configures the client to run in a browser.
void configureDiscordForBrowser() {
  w_transport.globalTransportPlatform = browserTransportPlatform;
  internals.operatingSystem = window.navigator.userAgent;
  internals.browser = true;
  internals.setup = true;
}
