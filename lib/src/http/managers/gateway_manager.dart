import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/gateway/event_parser.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/gateway/gateway.dart';

/// A [Manager] for gateway information.
// Use an abstract class so the client getter can be abstract,
// allowing us to override it in Gateway to have a more specific type.
abstract class GatewayManager with EventParser {
  /// The client this manager is for.
  NyxxRest get client;

  /// @nodoc
  // We need a constructor to be allowed to use this class as a superclass.
  GatewayManager.create();

  /// Create a new [GatewayManager].
  factory GatewayManager(NyxxRest client) = _GatewayManagerImpl;

  /// Fetch the current gateway configuration.
  Future<GatewayConfiguration> fetchGatewayConfiguration() async {
    final route = HttpRoute()..gateway();
    final request = BasicRequest(route, authenticated: false);

    final response = await client.httpHandler.executeSafe(request);
    return parseGatewayConfiguration(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch the current gateway configuration for the client.
  Future<GatewayBot> fetchGatewayBot() async {
    final route = HttpRoute()
      ..gateway()
      ..bot();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseGatewayBot(response.jsonBody as Map<String, Object?>);
  }
}

class _GatewayManagerImpl extends GatewayManager {
  @override
  final NyxxRest client;

  _GatewayManagerImpl(this.client) : super.create();
}
