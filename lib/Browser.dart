library nyxx.browser;

import 'dart:html';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;
import 'src/_internals.dart' show setup, browser, operatingSystem;

void configureNyxxForBrowser() {
  configureWTransportForBrowser();
  setup = true;
  browser = true;
  operatingSystem = window.navigator.userAgent;
}
