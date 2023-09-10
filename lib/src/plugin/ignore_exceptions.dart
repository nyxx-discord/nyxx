import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/plugin/plugin.dart';

/// A global instance of the [IgnoreExceptions] plugin.
final ignoreExceptions = IgnoreExceptions();

/// A plugin that prevents errors from crashing the program, instead logging them to the console.
class IgnoreExceptions extends NyxxPlugin {
  @override
  String get name => 'IgnoreExceptions';

  /// The logger used to report the errors.
  Logger get logger => Logger('IgnoreExceptions');

  static int _clients = 0;
  ReceivePort? _errorPort;

  void _listenIfNeeded() {
    if (_errorPort != null) {
      return;
    }

    _errorPort = ReceivePort();
    _errorPort!.listen((err) {
      final stackTrace = err[1] != null ? StackTrace.fromString(err[1] as String) : null;
      final message = err[0] as String;

      logger.shout('Unhandled exception was thrown', message, stackTrace);
    });

    Isolate.current.setErrorsFatal(false);
    Isolate.current.addErrorListener(_errorPort!.sendPort);
  }

  void _stopListeningIfNeeded() {
    if (_clients > 0) {
      return;
    }

    _stopListening();
  }

  void _stopListening() {
    Isolate.current.removeErrorListener(_errorPort!.sendPort);
    Isolate.current.setErrorsFatal(true);

    _errorPort?.close();
  }

  @override
  Future<ClientType> connect<ClientType extends Nyxx>(ApiOptions apiOptions, ClientOptions clientOptions, Future<ClientType> Function() connect) async {
    final client = await connect();

    _clients++;
    _listenIfNeeded();

    return client;
  }

  @override
  Future<void> close(Nyxx client, Future<void> Function() close) async {
    await close();
    _clients--;
    _stopListeningIfNeeded();
  }
}
