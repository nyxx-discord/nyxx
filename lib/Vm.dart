library nyxx.vm;

import 'dart:io';
import 'package:w_transport/vm.dart' show configureWTransportForVM;
import 'src/_internals.dart' show setup, browser, operatingSystem;

void configureNyxxForVM() {
  configureWTransportForVM();
  setup = true;
  browser = false;
  operatingSystem = Platform.operatingSystem;
}
