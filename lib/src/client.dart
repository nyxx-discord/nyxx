import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/handler.dart';
import 'package:nyxx/src/manager_mixin.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// The base class for clients interacting with the Discord API.
abstract class Nyxx {
  /// The options this client will use when connecting to the API.
  ApiOptions get apiOptions;

  /// The [HttpHandler] used by this client to make requests.
  HttpHandler get httpHandler;

  /// The options controlling the behavior of this client.
  ClientOptions get options;

  /// Create an instance of [NyxxRest] that can perform requests to the HTTP API and is
  /// authenticated with a bot token.
  static Future<NyxxRest> connectRest(String token, {RestClientOptions? options}) async {
    return NyxxRest._(token, options ?? RestClientOptions());
  }
}

/// A client that can make requests to the HTTP API and is authenticated with a bot token.
class NyxxRest with ManagerMixin implements Nyxx {
  @override
  final RestApiOptions apiOptions;

  @override
  final RestClientOptions options;

  @override
  late final HttpHandler httpHandler = HttpHandler(this);

  NyxxRest._(String token, this.options) : apiOptions = RestApiOptions(token: token);

  Future<void> joinThread(Snowflake id) => channels.joinThread(id);

  Future<void> leaveThread(Snowflake id) => channels.leaveThread(id);
}
