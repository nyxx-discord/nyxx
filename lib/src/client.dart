import 'package:nyxx/src/builders/presence.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/event_mixin.dart';
import 'package:nyxx/src/gateway/gateway.dart';
import 'package:nyxx/src/http/handler.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/intents.dart';
import 'package:nyxx/src/manager_mixin.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

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
  // TODO: Allow passing any RestApiOptions as configuration
  static Future<NyxxRest> connectRest(String token, {RestClientOptions? options}) async {
    return NyxxRest._(token, options ?? RestClientOptions());
  }

  /// Create an instance of [NyxxGateway] that can perform requests to the HTTP API, connects
  /// to the gateway and is authenticated with a bot token.
  // TODO: Allow passing any GatewayApiOptions as configuration
  static Future<NyxxGateway> connectGateway(String token, Flags<GatewayIntents> intents, {GatewayClientOptions? options}) async {
    final client = NyxxGateway._(token, intents, options ?? GatewayClientOptions());
    // We can't use client.gateway as it is not initialized yet
    final gatewayManager = GatewayManager(client);

    final gatewayBot = await gatewayManager.fetchGatewayBot();
    final gateway = await Gateway.connect(client, gatewayBot);

    return client..gateway = gateway;
  }

  /// Close this client and any underlying resources.
  ///
  /// The client should not be used after this is called and unexpected behavior may occur.
  Future<void> close();
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

  /// Add the current user to the thread with the ID [id].
  ///
  /// External references:
  /// * [ChannelManager.joinThread]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#join-thread
  Future<void> joinThread(Snowflake id) => channels.joinThread(id);

  /// Remove the current user from the thread with the ID [id].
  ///
  /// External references:
  /// * [ChannelManager.leaveThread]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#leave-thread
  Future<void> leaveThread(Snowflake id) => channels.leaveThread(id);

  @override
  Future<void> close() async => httpHandler.httpClient.close();
}

/// A client that can make requests to the HTTP API, connects to the Gateway and is authenticated with a bot token.
class NyxxGateway with ManagerMixin, EventMixin implements NyxxRest {
  @override
  final GatewayApiOptions apiOptions;

  @override
  final GatewayClientOptions options;

  @override
  late final HttpHandler httpHandler = HttpHandler(this);

  /// The [Gateway] used by this client to send and receive Gateway events.
  // Initialized in connectGateway due to a circular dependency
  @override
  late final Gateway gateway;

  NyxxGateway._(String token, Flags<GatewayIntents> intents, this.options) : apiOptions = GatewayApiOptions(token: token, intents: intents);

  @override
  Future<void> joinThread(Snowflake id) => channels.joinThread(id);

  @override
  Future<void> leaveThread(Snowflake id) => channels.leaveThread(id);

  /// Update the client's voice state in the guild with the ID [guildId].
  void updateVoiceState(Snowflake guildId, GatewayVoiceStateBuilder builder) => gateway.updateVoiceState(guildId, builder);

  /// Update the client's presence on all shards.
  void updatePresence(PresenceBuilder builder) => gateway.updatePresence(builder);

  @override
  Future<void> close() async {
    await gateway.close();
    httpHandler.httpClient.close();
  }
}
