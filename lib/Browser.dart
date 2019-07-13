library nyxx.browser;

import 'dart:html';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import 'src/_internals.dart' show setup, browser, operatingSystem;
import 'nyxx.dart';

export 'nyxx.dart';

class NyxxBrowser extends Nyxx {
  NyxxBrowser._private(String token, {ClientOptions options, bool ignoreExceptions = true}) : super(token, options: options, ignoreExceptions: ignoreExceptions);

  factory NyxxBrowser(String token, {ClientOptions options, bool ignoreExceptions = true}) {
    configureWTransportForBrowser();
    setup = true;
    browser = true;
    operatingSystem = window.navigator.userAgent;

    return NyxxBrowser._private(token, options: options, ignoreExceptions: ignoreExceptions);
  }
}