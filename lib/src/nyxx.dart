import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/core/channel/invite.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/application/client_oauth2_application.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/guild/client_user.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/guild_preview.dart';
import 'package:nyxx/src/core/guild/webhook.dart';
import 'package:nyxx/src/core/message/sticker.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/events/ready_event.dart';
import 'package:nyxx/src/internal/cache/cache.dart';
import 'package:nyxx/src/internal/connection_manager.dart';
import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/internal/event_controller.dart';
import 'package:nyxx/src/internal/exceptions/unrecoverable_nyxx_error.dart';
import 'package:nyxx/src/internal/http/http_response.dart';
import 'package:nyxx/src/internal/http_endpoints.dart';
import 'package:nyxx/src/internal/exceptions/missing_token_error.dart';
import 'package:nyxx/src/internal/http/http_handler.dart';
import 'package:nyxx/src/internal/interfaces/disposable.dart';
import 'package:nyxx/src/internal/shard/shard_manager.dart';
import 'package:nyxx/src/plugin/plugin.dart';
import 'package:nyxx/src/plugin/plugin_manager.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';
import 'package:nyxx/src/utils/builders/presence_builder.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class NyxxFactory {
  static INyxxRest createNyxxRest(String token, int intents, Snowflake appId, {ClientOptions? options, CacheOptions? cacheOptions}) =>
      NyxxRest(token, intents, appId, options: options, cacheOptions: cacheOptions);

  static INyxxWebsocket createNyxxWebsocket(String token, int intents, {ClientOptions? options, CacheOptions? cacheOptions}) =>
      NyxxWebsocket(token, intents, options: options, cacheOptions: cacheOptions);
}

/// Generic interface for Nyxx. Represents basic functionality of Nyxx that are always available.
abstract class INyxx implements Disposable, IPluginManager {
  /// Reference to HttpHandler
  HttpHandler get httpHandler;

  /// Returns handler for all available REST API action.
  IHttpEndpoints get httpEndpoints;

  /// Can be used to edit options after client initialised. Used by Nyxx.interactions to enable raw events
  ClientOptions get options;

  /// Options for cache handling in nyxx
  CacheOptions get cacheOptions;

  /// Token of instance
  String get token;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  SnowflakeCache<IGuild> get guilds;

  /// All of the channels the bot can see.
  SnowflakeCache<IChannel> get channels;

  /// All of the users the bot can see. Does not have offline users
  /// without `forceFetchUsers` enabled.
  SnowflakeCache<IUser> get users;

  /// Datetime when bot has started
  DateTime get startTime;

  /// True if client is ready.
  bool get ready;

  /// Id of bots application
  Snowflake get appId;

  /// Emitted when client is ready
  Stream<IReadyEvent> get onReady;

  Future<void> connect({bool propagateReady = true});
}

abstract class INyxxRest implements INyxx {
  /// When identifying to the gateway, you have to specify an intents parameter which
  /// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
  /// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
  /// Since api v8 its required upon connecting to gateway.
  int get intents;

  /// The current bot user.
  IClientUser get self;

  /// The bot"s OAuth2 app.
  IClientOAuth2Application get app;

  /// The current version of `nyxx`
  String get version;

  /// Gets an bot invite link with zero permissions
  String get inviteLink;

  /// Reference of event controller
  IRestEventController get eventsRest;
}

/// Lightweight client which do not start ws connections.
class NyxxRest extends INyxxRest {
  @override
  final String token;

  @override
  late final ClientOptions options;

  @override
  late final CacheOptions cacheOptions;

  @override
  late final HttpHandler httpHandler;

  @override
  late final IHttpEndpoints httpEndpoints;

  /// When identifying to the gateway, you have to specify an intents parameter which
  /// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
  /// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
  /// Since api v8 its required upon connecting to gateway.
  @override
  final int intents;

  /// The current bot user.
  @override
  late IClientUser self;

  /// The bot"s OAuth2 app.
  @override
  late IClientOAuth2Application app;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  @override
  late final SnowflakeCache<Guild> guilds;

  /// All of the channels the bot can see.
  @override
  late final SnowflakeCache<IChannel> channels;

  /// All of the users the bot can see. Does not have offline users
  /// without `forceFetchUsers` enabled.
  @override
  late final SnowflakeCache<IUser> users;

  /// True if client is ready.
  @override
  bool ready = false;

  /// The current version of `nyxx`
  @override
  String get version => Constants.version;

  /// Gets an bot invite link with zero permissions
  @override
  String get inviteLink => app.getInviteUrl();

  @override
  late final RestEventController eventsRest;

  /// Date time when bot was started
  @override
  final DateTime startTime = DateTime.now();

  @override
  late final Stream<IReadyEvent> onReady = onReadyController.stream;
  late final StreamController<IReadyEvent> onReadyController = StreamController.broadcast();

  @override
  Snowflake get appId => _appId;

  @override
  Iterable<BasePlugin> get plugins => _plugins;

  final Snowflake _appId;
  final Logger _logger = Logger("Client");
  final List<BasePlugin> _plugins = [];

  /// Creates and logs in a new client. If [ignoreExceptions] is true (by default is)
  /// isolate will ignore all exceptions and continue to work.
  NyxxRest(this.token, this.intents, this._appId, {ClientOptions? options, CacheOptions? cacheOptions}) {
    _logger.fine("Staring Nyxx: intents: [$intents]");

    if (token.isEmpty) {
      throw MissingTokenError();
    }

    this.options = options ?? ClientOptions();
    this.cacheOptions = cacheOptions ?? CacheOptions();

    guilds = SnowflakeCache();
    channels = SnowflakeCache();
    users = SnowflakeCache();

    eventsRest = RestEventController();
  }

  @override
  Future<void> connect({bool propagateReady = true}) async {
    httpHandler = HttpHandler(this);
    httpEndpoints = HttpEndpoints(this);

    if (propagateReady) {
      onReadyController.add(ReadyEvent(this));

      for (final plugin in _plugins) {
        await plugin.onBotStart(this, _logger);
      }
    }
  }

  @override
  Future<void> dispose() async {
    for (final plugin in _plugins) {
      await plugin.onBotStop(this, _logger);
    }

    await eventsRest.dispose();

    onReadyController.close();

    await guilds.dispose();
    await users.dispose();
    await channels.dispose();
  }

  @override
  void registerPlugin<T extends BasePlugin>(T pluginInstance) {
    pluginInstance.onRegister(this, _logger);
    _plugins.add(pluginInstance);
  }
}

abstract class INyxxWebsocket implements INyxxRest {
  /// Event controller for websocket events
  IWebsocketEventController get eventsWs;

  /// Current client"s shard
  IShardManager get shardManager;

  /// This endpoint is only for public guilds if bot is not int the guild.
  Future<IGuildPreview> fetchGuildPreview(Snowflake guildId);

  /// Returns guild with given [guildId]
  /// If [withCounts] is set to true, then guild will have [IGuild.approximateMemberCount] and [IGuild.approximatePresenceCount] present.
  Future<IGuild> fetchGuild(Snowflake guildId, {bool? withCounts = true});

  /// Creates a guild.
  ///
  /// **⚠️ This endpoint can only be used by bots that are in ten guilds or fewer.**
  /// ```dart
  /// var gb = GuildBuilder("Test Guild");
  /// var guild = await client.createGuild(gb);
  /// ```
  Future<IGuild> createGuild(GuildBuilder builder);

  /// Returns channel with specified id.
  /// ```
  /// var channel = await client.fetchChannel<ITextChannel>(Snowflake("473853847115137024"));
  /// ```
  Future<T> fetchChannel<T extends IChannel>(Snowflake channelId);

  /// Get user instance with specified id.
  /// ```dart
  /// var user = await client.fetchUser(Snowflake("302359032612651009"));
  /// ```
  Future<IUser> fetchUser(Snowflake userId);

  /// Gets a webhook by its id and/or token.
  /// If token is supplied authentication is not needed.
  Future<IWebhook> fetchWebhook(Snowflake id, {String token = ""});

  /// Gets an [Invite] object with given code.
  /// If the [code] is in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var inv = client.getInvite("YMgffU8");
  /// ```
  Future<IInvite> getInvite(String code);

  /// Returns number of shards
  int get shards;

  /// Sets presence for bot.
  ///
  /// Code below will display bot presence as `Playing Super duper game`:
  /// ```dart
  /// bot.setPresence(
  ///   PresenceBuilder.of(
  ///     activity: ActivityBuilder.game("Super duper game"),
  ///   ),
  /// );
  /// ```
  ///
  /// Bots cannot set custom status - only game, listening and stream available.
  ///
  /// To set bot presence to streaming use:
  /// ```dart
  /// bot.setPresence(
  ///   PresenceBuilder.of(
  ///     activity: ActivityBuilder.streaming("Super duper game", "https://twitch.tv/l7ssha"),
  ///   ),
  /// );
  /// ```
  void setPresence(PresenceBuilder presenceBuilder);

  /// Join [ThreadChannel] with given [channelId]
  Future<void> joinThread(Snowflake channelId) => httpEndpoints.joinThread(channelId);

  /// Gets standard sticker with given id
  Future<IStandardSticker> getSticker(Snowflake id);

  /// List all nitro stickers packs
  Stream<IStickerPack> listNitroStickerPacks();
}

/// The main place to start with interacting with the Discord API and creating discord bot.
/// From there you can subscribe to various [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// and fetch data from API with provided methods or get cached data.
///
/// Creating new instance of bot:
/// ```
/// Nyxx("<TOKEN>");
/// ```
/// After initializing nyxx you can subscribe to events:
/// ```
/// client.onReady.listen((e) => print("Ready!"));
///
/// client.onRoleCreate.listen((e) {
///   print("Role created with name: ${e.role.name});
/// });
/// ```
/// or setup `CommandsFramework` and `Voice`.
class NyxxWebsocket extends NyxxRest implements INyxxWebsocket {
  late final ConnectionManager ws;

  /// Current client"s shard
  @override
  late final IShardManager shardManager;

  @override
  late final IWebsocketEventController eventsWs;

  @override
  Snowflake get appId => app.id;

  /// Creates and logs in a new client. If [ignoreExceptions] is true (by default is)
  /// isolate will ignore all exceptions and continue to work.
  NyxxWebsocket(String token, int intents, {ClientOptions? options, CacheOptions? cacheOptions})
      : super(token, intents, Snowflake.zero(), options: options, cacheOptions: cacheOptions) {
    eventsWs = WebsocketEventController(this);
  }

  @override
  Future<void> connect({bool propagateReady = true}) async {
    await super.connect(propagateReady: false);

    final httpResponse = await (httpEndpoints as HttpEndpoints).getMeApplication();
    if (httpResponse is HttpResponseSuccess) {
      app = ClientOAuth2Application(httpResponse.jsonBody as RawApiMap, this);
    } else {
      throw UnrecoverableNyxxError("Cannot get bot identity: `${httpResponse.toString()}`");
    }

    ws = ConnectionManager(this);
    await ws.connect();

    if (propagateReady) {
      onReadyController.add(ReadyEvent(this));

      for (final plugin in _plugins) {
        await plugin.onBotStart(this, _logger);
      }
    }
  }

  /// This endpoint is only for public guilds if bot is not int the guild.
  @override
  Future<IGuildPreview> fetchGuildPreview(Snowflake guildId) async => httpEndpoints.fetchGuildPreview(guildId);

  /// Returns guild with given [guildId]
  /// If [withCounts] is set to true, then guild will have [IGuild.approximateMemberCount] and [IGuild.approximatePresenceCount] present.
  @override
  Future<IGuild> fetchGuild(Snowflake guildId, {bool? withCounts = true}) => httpEndpoints.fetchGuild(guildId, withCounts: withCounts);

  /// Returns channel with specified id.
  /// ```
  /// var channel = await client.fetchChannel<ITextChannel>(Snowflake("473853847115137024"));
  /// ```
  @override
  Future<T> fetchChannel<T extends IChannel>(Snowflake channelId) => httpEndpoints.fetchChannel(channelId);

  /// Get user instance with specified id.
  /// ```
  /// var user = client.getUser(Snowflake("302359032612651009"));
  /// ```
  @override
  Future<IUser> fetchUser(Snowflake userId) => httpEndpoints.fetchUser(userId);

  /// Creates a guild.
  ///
  /// **⚠️ This endpoint can only be used by bots that are in ten guilds or fewer.**
  /// ```dart
  /// var gb = GuildBuilder("Test Guild");
  /// var guild = await client.createGuild(gb);
  /// ```
  @override
  Future<IGuild> createGuild(GuildBuilder builder) => httpEndpoints.createGuild(builder);

  /// Gets a webhook by its id and/or token.
  /// If token is supplied authentication is not needed.
  @override
  Future<IWebhook> fetchWebhook(Snowflake id, {String token = ""}) => httpEndpoints.fetchWebhook(id, token: token);

  /// Gets an [Invite] object with given code.
  /// If the [code] is in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var inv = client.getInvite("YMgffU8");
  /// ```
  @override
  Future<IInvite> getInvite(String code) => httpEndpoints.fetchInvite(code);

  /// Returns number of shards
  @override
  int get shards => shardManager.shards.length;

  /// Sets presence for bot.
  ///
  /// Code below will display bot presence as `Playing Super duper game`:
  /// ```dart
  /// bot.setPresence(game: Activity.of("Super duper game"))
  /// ```
  ///
  /// Bots cannot set custom status - only game, listening and stream available.
  ///
  /// To set bot presence to streaming use:
  /// ```dart
  /// bot.setPresence(game: Activity.of("Super duper game", type: ActivityType.streaming, url: "https://twitch.tv/l7ssha"))
  /// ```
  /// `url` property in `Activity` can be only set when type is set to `streaming`
  @override
  void setPresence(PresenceBuilder presenceBuilder) {
    shardManager.setPresence(presenceBuilder);
  }

  /// Join [ThreadChannel] with given [channelId]
  @override
  Future<void> joinThread(Snowflake channelId) => httpEndpoints.joinThread(channelId);

  /// Gets standard sticker with given id
  @override
  Future<IStandardSticker> getSticker(Snowflake id) => httpEndpoints.getSticker(id);

  /// List all nitro stickers packs
  @override
  Stream<IStickerPack> listNitroStickerPacks() => httpEndpoints.listNitroStickerPacks();

  @override
  Future<void> dispose() async {
    _logger.info("Disposing and closing bot...");

    await super.dispose();

    if (options.shutdownHook != null) {
      await options.shutdownHook!(this);
    }

    await shardManager.dispose();
    await eventsWs.dispose();

    _logger.info("Bot disposed.");
  }
}
