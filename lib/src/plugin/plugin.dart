import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/handler.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/response.dart';
import 'package:runtime_type/runtime_type.dart';

/// Provides access to the connection and closing process for implementing plugins.
abstract class NyxxPlugin<ClientType extends Nyxx> {
  /// The name of this plugin.
  String get name => runtimeType.toString();

  /// A logger that can be used to log messages from this plugin.
  Logger get logger => Logger(name);

  /// The type of client this plugin requires.
  RuntimeType<ClientType> get clientType => RuntimeType<ClientType>();

  late final Expando<NyxxPluginState<ClientType, NyxxPlugin<ClientType>>> _states = Expando('$name plugin states');

  /// Perform the connection operation.
  ///
  /// People overriding this method should call it to obtain the client instance.
  @mustCallSuper
  Future<ClientType> doConnect(ApiOptions apiOptions, ClientOptions clientOptions, Future<ClientType> Function() connect) async {
    final state = await createState();
    await state.beforeConnect(apiOptions, clientOptions);

    final client = await connect();
    _states[client] = state;

    await state.afterConnect(client);
    return client;
  }

  /// Perform the close operation.
  ///
  /// People overriding this method should call it to obtain the client instance.
  @mustCallSuper
  Future<void> doClose(ClientType client, Future<void> Function() close) async {
    final state = _states[client];
    await state?.beforeClose(client);

    await close();
    _states[client] = null;

    await state?.afterClose();
  }

  /// Called to create the state for this plugin.
  ///
  /// Each plugin creates a state for each client is attached to. States can contain mutable fields that can be updated at any time without affecting other
  /// instances of the plugin attached to other clients.
  FutureOr<NyxxPluginState<ClientType, NyxxPlugin<ClientType>>> createState() => NyxxPluginState(this);

  /// Called before each client this plugin is added to connects.
  FutureOr<void> beforeConnect(ApiOptions apiOptions, ClientOptions clientOptions) {}

  /// Called after each client this plugin is added to connects.
  FutureOr<void> afterConnect(ClientType client) {}

  /// Called before each client this plugin is added to closes.
  FutureOr<void> beforeClose(ClientType client) {}

  /// Called after each client this plugin is added to closes.
  FutureOr<void> afterClose() {}

  /// Called whenever a request is made using a client's [HttpHandler].
  ///
  /// Plugins that implement this method are not required to call the [next] method.
  @mustCallSuper
  Future<HttpResponse> interceptRequest(ClientType client, HttpRequest request, Future<HttpResponse> Function(HttpRequest) next) {
    final state = _states[client];
    return state?.interceptRequest(client, request, next) ?? next(request);
  }
}

/// Holds the state of a plugin added to a client.
class NyxxPluginState<ClientType extends Nyxx, PluginType extends NyxxPlugin<ClientType>> {
  /// The plugin this state belongs to.
  final PluginType plugin;

  /// A logger that can be used to log messages from this plugin.
  Logger get logger => plugin.logger;

  /// Create a new plugin state.
  NyxxPluginState(this.plugin);

  /// Called before each client this plugin is added to connects.
  @mustCallSuper
  FutureOr<void> beforeConnect(ApiOptions apiOptions, ClientOptions clientOptions) => plugin.beforeConnect(apiOptions, clientOptions);

  /// Called after each client this plugin is added to connects.
  @mustCallSuper
  FutureOr<void> afterConnect(ClientType client) => plugin.afterConnect(client);

  /// Called before each client this plugin is added to closes.
  @mustCallSuper
  FutureOr<void> beforeClose(ClientType client) => plugin.beforeClose(client);

  /// Called after each client this plugin is added to closes.
  @mustCallSuper
  FutureOr<void> afterClose() => plugin.afterClose();

  /// Called whenever a request is made using a client's [HttpHandler].
  ///
  /// Plugins that implement this method are not required to call the [next] method.
  Future<HttpResponse> interceptRequest(ClientType client, HttpRequest request, Future<HttpResponse> Function(HttpRequest) next) => next(request);
}
