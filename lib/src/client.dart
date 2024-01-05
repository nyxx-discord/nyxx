import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:nyxx/src/builders/presence.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/event_mixin.dart';
import 'package:nyxx/src/gateway/gateway.dart';
import 'package:nyxx/src/http/handler.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/intents.dart';
import 'package:nyxx/src/manager_mixin.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/plugin/plugin.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:oauth2/oauth2.dart';
import 'package:runtime_type/runtime_type.dart';

/// A helper function to nest and execute calls to plugin connect methods.
Future<T> _doConnect<T extends Nyxx>(ApiOptions apiOptions, ClientOptions clientOptions, Future<T> Function() connect, List<NyxxPlugin> plugins) {
  final actualClientType = RuntimeType<T>();

  for (final plugin in plugins) {
    if (!actualClientType.isSubtypeOf(plugin.clientType)) {
      throw PluginError('Unsupported client type: plugin needs ${plugin.clientType.internalType}, client was ${actualClientType.internalType}');
    }
  }

  final originalConnect = connect;

  connect = plugins.fold(
    () async => await originalConnect()
      .._initializedCompleter.complete(),
    (previousConnect, plugin) => () async => actualClientType.castInstance(await plugin.doConnect(apiOptions, clientOptions, previousConnect)),
  );

  return connect();
}

/// A helper function to nest and execute calls to plugin close methods.
Future<void> _doClose(Nyxx client, Future<void> Function() close, List<NyxxPlugin> plugins) {
  close = plugins.fold(
    close,
    (previousClose, plugin) => () => plugin.doClose(client, previousClose),
  );
  return close();
}

@internal
extension InternalReady on Nyxx {
  /// A future that completes when this client is initialized and can be passed to user defined callbacks.
  @internal
  Future<void> get initialized => _initializedCompleter.future;
}

/// The base class for clients interacting with the Discord API.
abstract class Nyxx {
  /// The options this client will use when connecting to the API.
  ApiOptions get apiOptions;

  /// The [HttpHandler] used by this client to make requests.
  HttpHandler get httpHandler;

  /// The options controlling the behavior of this client.
  ClientOptions get options;

  /// The logger for this client.
  Logger get logger;

  Completer<void> get _initializedCompleter;

  /// Create an instance of [NyxxRest] that can perform requests to the HTTP API and is
  /// authenticated with a bot token.
  static Future<NyxxRest> connectRest(String token, {RestClientOptions options = const RestClientOptions()}) =>
      connectRestWithOptions(RestApiOptions(token: token), options);

  /// Create an instance of [NyxxRest] using the provided options.
  static Future<NyxxRest> connectRestWithOptions(RestApiOptions apiOptions, [RestClientOptions clientOptions = const RestClientOptions()]) async {
    clientOptions.logger
      ..info('Connecting to the REST API')
      ..fine('Token: ${apiOptions.token}, Authorization: ${apiOptions.authorizationHeader}, User-Agent: ${apiOptions.userAgent}')
      ..fine('Plugins: ${clientOptions.plugins.map((plugin) => plugin.name).join(', ')}');

    return _doConnect(apiOptions, clientOptions, () async {
      final client = NyxxRest._(apiOptions, clientOptions);

      return client
        .._application = await client.applications.fetchCurrentApplication()
        .._user = await client.users.fetchCurrentUser();
    }, clientOptions.plugins);
  }

  /// Create an instance of [NyxxOAuth2] that can perform requests to the HTTP API and is
  /// authenticated with OAuth2 [Credentials].
  static Future<NyxxOAuth2> connectOAuth2(Credentials credentials, {RestClientOptions options = const RestClientOptions()}) =>
      connectOAuth2WithOptions(OAuth2ApiOptions(credentials: credentials), options);

  /// Create an instance of [NyxxOAuth2] using the provided options.
  static Future<NyxxOAuth2> connectOAuth2WithOptions(OAuth2ApiOptions apiOptions, [RestClientOptions clientOptions = const RestClientOptions()]) async {
    clientOptions.logger
      ..info('Connecting to the REST API via OAuth2')
      ..fine('Token: ${apiOptions.token}, Authorization: ${apiOptions.authorizationHeader}, User-Agent: ${apiOptions.userAgent}')
      ..fine('Plugins: ${clientOptions.plugins.map((plugin) => plugin.name).join(', ')}');

    return _doConnect(apiOptions, clientOptions, () async {
      final client = NyxxOAuth2._(apiOptions, clientOptions);

      return client
        .._application = await client.applications.fetchCurrentApplication()
        .._user = await client.users.fetchCurrentUser();
    }, clientOptions.plugins);
  }

  /// Create an instance of [NyxxGateway] that can perform requests to the HTTP API, connects
  /// to the gateway and is authenticated with a bot token.
  static Future<NyxxGateway> connectGateway(String token, Flags<GatewayIntents> intents, {GatewayClientOptions options = const GatewayClientOptions()}) =>
      connectGatewayWithOptions(GatewayApiOptions(token: token, intents: intents), options);

  /// Create an instance of [NyxxGateway] using the provided options.
  static Future<NyxxGateway> connectGatewayWithOptions(
    GatewayApiOptions apiOptions, [
    GatewayClientOptions clientOptions = const GatewayClientOptions(),
  ]) async {
    clientOptions.logger
      ..info('Connecting to the Gateway API')
      ..fine(
        'Token: ${apiOptions.token}, Authorization: ${apiOptions.authorizationHeader}, User-Agent: ${apiOptions.userAgent},'
        ' Intents: ${apiOptions.intents.value}, Payloads: ${apiOptions.payloadFormat.value}, Compression: ${apiOptions.compression.name},'
        ' Shards: ${apiOptions.shards?.join(', ')}, Total shards: ${apiOptions.totalShards}, Large threshold: ${apiOptions.largeThreshold}',
      )
      ..fine('Plugins: ${clientOptions.plugins.map((plugin) => plugin.name).join(', ')}');

    return _doConnect(apiOptions, clientOptions, () async {
      final client = NyxxGateway._(apiOptions, clientOptions);

      client
        .._application = await client.applications.fetchCurrentApplication()
        .._user = await client.users.fetchCurrentUser();

      // We can't use client.gateway as it is not initialized yet
      final gatewayManager = GatewayManager(client);

      final gatewayBot = await gatewayManager.fetchGatewayBot();
      return client..gateway = await Gateway.connect(client, gatewayBot);
    }, clientOptions.plugins);
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

  /// The application associated with this client.
  PartialApplication get application => _application;
  late final PartialApplication _application;

  /// The user associated with this client.
  PartialUser get user => _user;
  late final PartialUser _user;

  @override
  Logger get logger => options.logger;

  @override
  final Completer<void> _initializedCompleter = Completer();

  NyxxRest._(this.apiOptions, this.options);

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

  /// List the guilds the current user is a member of.
  Future<List<PartialGuild>> listGuilds({Snowflake? before, Snowflake? after, int? limit}) =>
      users.listCurrentUserGuilds(before: before, after: after, limit: limit);

  @override
  Future<void> close() {
    logger.info('Closing client');
    return _doClose(this, () async => httpHandler.close(), options.plugins);
  }
}

class NyxxOAuth2 with ManagerMixin implements NyxxRest {
  @override
  final OAuth2ApiOptions apiOptions;

  @override
  final RestClientOptions options;

  @override
  late final HttpHandler httpHandler = Oauth2HttpHandler(this);

  @override
  Logger get logger => options.logger;

  @override
  PartialApplication get application => _application;

  @override
  late final PartialApplication _application;

  @override
  PartialUser get user => _user;

  @override
  late final PartialUser _user;

  @override
  final Completer<void> _initializedCompleter = Completer();

  NyxxOAuth2._(this.apiOptions, this.options);

  @override
  Future<void> joinThread(Snowflake id) => channels.joinThread(id);

  @override
  Future<void> leaveThread(Snowflake id) => channels.leaveThread(id);

  @override
  Future<List<PartialGuild>> listGuilds({Snowflake? before, Snowflake? after, int? limit}) =>
      users.listCurrentUserGuilds(before: before, after: after, limit: limit);

  @override
  Future<void> close() {
    logger.info('Closing client');
    return _doClose(this, () async => httpHandler.close(), options.plugins);
  }
}

/// A client that can make requests to the HTTP API, connects to the Gateway and is authenticated with a bot token.
class NyxxGateway with ManagerMixin, EventMixin implements NyxxRest {
  @override
  final GatewayApiOptions apiOptions;

  @override
  final GatewayClientOptions options;

  @override
  late final HttpHandler httpHandler = HttpHandler(this);

  @override
  PartialApplication get application => _application;

  @override
  late final PartialApplication _application;

  @override
  PartialUser get user => _user;

  @override
  late final PartialUser _user;

  /// The [Gateway] used by this client to send and receive Gateway events.
  // Initialized in connectGateway due to a circular dependency
  @override
  late final Gateway gateway;

  @override
  Logger get logger => options.logger;

  @override
  final Completer<void> _initializedCompleter = Completer();

  NyxxGateway._(this.apiOptions, this.options);

  @override
  Future<void> joinThread(Snowflake id) => channels.joinThread(id);

  @override
  Future<void> leaveThread(Snowflake id) => channels.leaveThread(id);

  @override
  Future<List<PartialGuild>> listGuilds({Snowflake? before, Snowflake? after, int? limit}) =>
      users.listCurrentUserGuilds(before: before, after: after, limit: limit);

  /// Update the client's voice state in the guild with the ID [guildId].
  void updateVoiceState(Snowflake guildId, GatewayVoiceStateBuilder builder) => gateway.updateVoiceState(guildId, builder);

  /// Update the client's presence on all shards.
  void updatePresence(PresenceBuilder builder) => gateway.updatePresence(builder);

  @override
  Future<void> close() {
    logger.info('Closing client');
    return _doClose(this, () async {
      await gateway.close();
      httpHandler.close();
    }, options.plugins);
  }
}
