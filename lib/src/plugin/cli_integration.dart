import 'dart:async';
import 'dart:io';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/plugin/plugin.dart';

/// A global instance of the [CliIntegration] plugin.
final cliIntegration = CliIntegration();

/// A plugin that lets clients close their session gracefully when the process is terminated.
class CliIntegration extends NyxxPlugin {
  final Set<Nyxx> _watchedClients = {};
  List<StreamSubscription<ProcessSignal>>? _subscriptions;

  void _ensureListening() {
    void closeClients(ProcessSignal signal) async {
      await Future.wait(Set.of(_watchedClients).map((client) => client.close()));

      // Our listeners will have been removed, send the signal again to either terminate the process or let
      // other signal handlers handle it.
      // This will end up calling other signal handlers twice.
      Process.killPid(pid, signal);
    }

    _subscriptions ??= [
      ProcessSignal.sigint.watch().listen(closeClients),
      if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(closeClients),
    ];
  }

  void _removeListenersIfNeeded() {
    if (_subscriptions == null || _watchedClients.isNotEmpty) {
      return;
    }

    for (final subscription in _subscriptions!) {
      subscription.cancel();
    }
  }

  @override
  Future<ClientType> connect<ClientType extends Nyxx>(Future<ClientType> Function() connect) async {
    _ensureListening();

    try {
      final client = await connect();
      _watchedClients.add(client);
      return client;
    } finally {
      _removeListenersIfNeeded();
    }
  }

  @override
  Future<void> close(Nyxx client, Future<void> Function() close) async {
    _watchedClients.remove(client);
    _removeListenersIfNeeded();
    await close();
  }
}
