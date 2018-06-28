library nyxx.setup;

import 'dart:io' as vm;
import 'dart:html' as web;
import 'src/internals.dart' as internals;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm.dart' show vmTransportPlatform;
import 'package:w_transport/browser.dart' show browserTransportPlatform;

/// Configures the client to run in Dart VM.
void configureDiscordForVM() {
  w_transport.globalTransportPlatform = vmTransportPlatform;
  internals.operatingSystem = vm.Platform.operatingSystem;
  internals.setup = true;
}

/// Configures the client to run in a browser.
void configureDiscordForBrowser() {
  w_transport.globalTransportPlatform = browserTransportPlatform;
  internals.operatingSystem = web.window.navigator.userAgent;
  internals.browser = true;
  internals.setup = true;
}