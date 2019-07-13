library nyxx.vm;

import 'dart:io';
import 'package:w_transport/vm.dart' show configureWTransportForVM;

import 'src/_internals.dart' show setup, browser, operatingSystem;
import 'nyxx.dart';

export 'nyxx.dart';

class NyxxVm extends Nyxx {
  NyxxVm._private(String token, {ClientOptions options, bool ignoreExceptions = true}) : super(token, options: options, ignoreExceptions: ignoreExceptions);

  factory NyxxVm(String token, {ClientOptions options, bool ignoreExceptions = true}) {
    configureWTransportForVM();
    setup = true;
    browser = false;
    operatingSystem = Platform.operatingSystem;

    return NyxxVm._private(token, options: options, ignoreExceptions: ignoreExceptions);
  }
}
