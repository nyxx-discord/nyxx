library nyxx.browser;

import 'dart:html';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import 'src/_internals.dart' show setup, browser, operatingSystem;
import 'nyxx.dart';

export 'nyxx.dart';

Nyxx NyxxBrowser(String token, {ClientOptions? options, bool ignoreExceptions = true}) {
  configureWTransportForBrowser();
  setup = true;
  browser = false;
  operatingSystem = window.navigator.userAgent;

  return Nyxx(token,
      options: options, ignoreExceptions: ignoreExceptions);
}
