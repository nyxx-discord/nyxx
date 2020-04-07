library nyxx.browser;

import 'dart:html';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import 'src/_internals.dart' show setup, browser, operatingSystem;
import 'nyxx.dart';

export 'nyxx.dart';

/// Subclass of Nyxx class intended to be used in browser environment
class NyxxBrowser extends Nyxx {
  NyxxBrowser._private(String token,
      {ClientOptions? options, bool ignoreExceptions = true})
      : super(token, options: options, ignoreExceptions: ignoreExceptions);

  /// Sets up nyxx for browser usage and returns new Nyxx instance
  factory NyxxBrowser(String token,
      {ClientOptions? options, bool ignoreExceptions = true}) {
    configureWTransportForBrowser();
    setup = true;
    browser = true;
    operatingSystem = window.navigator.userAgent;

    return NyxxBrowser._private(token,
        options: options, ignoreExceptions: ignoreExceptions);
  }
}
