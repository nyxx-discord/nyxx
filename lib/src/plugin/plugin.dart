import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';

/// Provides access to the connection and closing process for implementing plugins.
abstract class NyxxPlugin {
  /// The name of this plugin.
  String get name;

  /// Perform the connection operation.
  ///
  /// The function passed as an argument should be called to obtain the underlying client.
  Future<ClientType> connect<ClientType extends Nyxx>(ApiOptions apiOptions, ClientOptions clientOptions, Future<ClientType> Function() connect) => connect();

  /// Perform the close operation.
  ///
  /// The function passed as an argument should be called to close the underlying client.
  Future<void> close(Nyxx client, Future<void> Function() close) => close();
}
