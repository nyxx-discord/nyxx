import 'http_route_param.dart';
import 'http_route_part.dart';

/// Builds routes according to Discord's dynamic bucket rate limiting scheme.
///
/// Use builder syntax such as:
/// ```dart
/// var route = HttpRoute()..guilds(id: id)..members()..search();
/// ```
/// to keep route definitions brief while reusing route rate limiting definitions.
/// If creating custom routes with [add], remember to comply with Discord's
/// rate limiting scheme by toggling the appropriate [HttpRouteParam.isMajor].
abstract class IHttpRoute {
  /// Creates a new empty [IHttpRoute].
  factory IHttpRoute() = HttpRoute;

  /// Adds a [HttpRoutePart] to this [IHttpRoute].
  void add(HttpRoutePart httpRoutePart);

  /// Adds the [`guilds`](https://discord.com/developers/docs/resources/guild#get-guild) part to this [IHttpRoute].
  void guilds({String? id});

  /// Adds the [`channels`](https://discord.com/developers/docs/resources/channel#get-channel) part to this [IHttpRoute].
  void channels({String? id});

  /// Adds the [`webhooks`](https://discord.com/developers/docs/resources/webhook#get-webhook) part to this [IHttpRoute].
  void webhooks({String? id, String? token});

  /// Adds the [`reactions`](https://discord.com/developers/docs/resources/channel#get-reactions) part to this [IHttpRoute].
  void reactions({String? emoji, String? userId});

  /// Adds the [`emojis`](https://discord.com/developers/docs/resources/emoji#get-guild-emoji) part to this [IHttpRoute].
  void emojis({String? id});

  /// Adds the [`roles`](https://discord.com/developers/docs/resources/guild#get-guild-roles) part to this [IHttpRoute].
  void roles({String? id});

  /// Adds the [`members`](https://discord.com/developers/docs/resources/guild#get-guild-member) part to this [IHttpRoute].
  void members({String? id});

  /// Adds the [`bans`](https://discord.com/developers/docs/resources/guild#get-guild-bans) part to this [IHttpRoute].
  void bans({String? id});

  /// Adds the [`users`](https://discord.com/developers/docs/resources/user#get-user) part to this [IHttpRoute].
  void users({String? id});

  /// Adds the [`permissions`](https://discord.com/developers/docs/interactions/application-commands#get-guild-application-command-permissions) part to this [IHttpRoute].
  void permissions({String? id});

  /// Adds the [`messages`](https://discord.com/developers/docs/resources/channel#get-channel-messages) part to this [IHttpRoute].
  void messages({String? id});

  /// Adds the [`pins`](https://discord.com/developers/docs/resources/channel#get-pinned-messages) part to this [IHttpRoute].
  void pins({String? id});

  /// Adds the [`invites`](https://discord.com/developers/docs/resources/guild#get-guild-invites) part to this [IHttpRoute].
  void invites({String? id});

  /// Adds the [`applications`](https://discord.com/developers/docs/topics/oauth2#get-current-bot-application-information) part to this [IHttpRoute].
  void applications({String? id});

  /// Adds the [`stage-instances`](https://discord.com/developers/docs/resources/stage-instance#get-stage-instance) part to this [IHttpRoute].
  void stageinstances({String? id});

  /// Adds the [`thread-members`](https://discord.com/developers/docs/resources/channel#get-thread-member) part to this [IHttpRoute].
  void threadMembers({String? id});

  /// Adds the [`stickers`](https://discord.com/developers/docs/resources/sticker#get-sticker) part to this [IHttpRoute].
  void stickers({String? id});

  /// Adds the `avatars` part to this [IHttpRoute].
  ///
  /// Note: this part only exists for the Discord CDN.
  void avatars();

  /// Adds the [`scheduled-events`](https://discord.com/developers/docs/resources/guild-scheduled-event#get-guild-scheduled-event) part to this [IHttpRoute].
  void scheduledEvents({String? id});

  /// Adds the [`prune`](https://discord.com/developers/docs/resources/guild#get-guild-prune-count) part to this [IHttpRoute].
  void prune();

  /// Adds the [`nick`](https://discord.com/developers/docs/resources/guild#modify-current-user-nick) part to this [IHttpRoute].
  void nick();

  /// Adds the [`audit-logs`](https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log) part to this [IHttpRoute].
  void auditlogs();

  /// Adds the [`regions`](https://discord.com/developers/docs/resources/voice#list-voice-regions) part to this [IHttpRoute].
  void regions();

  /// Adds the [`search`](https://discord.com/developers/docs/resources/guild#search-guild-members) part to this [IHttpRoute].
  void search();

  /// Adds the [`bulk-delete`](https://discord.com/developers/docs/resources/channel#bulk-delete-messages) part to this [IHttpRoute].
  void bulkdelete();

  /// Adds the [`typing`](https://discord.com/developers/docs/resources/channel#trigger-typing-indicator) part to this [IHttpRoute].
  void typing();

  /// Adds the [`crosspost`](https://discord.com/developers/docs/resources/channel#crosspost-message) part to this [IHttpRoute].
  void crosspost();

  /// Adds the [`threads`](https://discord.com/developers/docs/resources/channel#start-thread-from-message) part to this [IHttpRoute].
  void threads();

  /// Adds the [`gateway`](https://discord.com/developers/docs/topics/gateway#get-gateway) part to this [IHttpRoute].
  void gateway();

  /// Adds the [`bot`](https://discord.com/developers/docs/topics/gateway#get-gateway-bot) part to this [IHttpRoute].
  void bot();

  /// Adds the [`oauth2`](https://discord.com/developers/docs/topics/oauth2#get-current-authorization-information) part to this [IHttpRoute].
  void oauth2();

  /// Adds the [`preview`](https://discord.com/developers/docs/resources/guild#get-guild-preview) part to this [IHttpRoute].
  void preview();

  /// Adds the [`active`](https://discord.com/developers/docs/resources/guild#list-active-guild-threads) part to this [IHttpRoute].
  void active();

  /// Adds the [`archived`](https://discord.com/developers/docs/resources/channel#list-public-archived-threads) part to this [IHttpRoute].
  void archived();

  /// Adds the [`private`](https://discord.com/developers/docs/resources/channel#list-private-archived-threads) part to this [IHttpRoute].
  void private();

  /// Adds the [`public`](https://discord.com/developers/docs/resources/channel#list-public-archived-threads) part to this [IHttpRoute].
  void public();

  /// Adds the [`sticker-packs`](https://discord.com/developers/docs/resources/sticker#list-nitro-sticker-packs) part to this [IHttpRoute].
  void stickerpacks();

  /// Adds the [`welcome-screen`](https://discord.com/developers/docs/resources/guild#get-guild-welcome-screen) part to this [IHttpRoute].
  void welcomeScreen();
}

class HttpRoute implements IHttpRoute {
  final List<HttpRoutePart> _httpRouteParts = [];

  List<String> get pathSegments => _httpRouteParts
      .expand((part) => [
            part.path,
            ...part.params.map((param) => param.param),
          ])
      .toList();

  String get path => "/" + pathSegments.join("/");

  String get routeId => _httpRouteParts
      .expand((part) => [
            part.path,
            ...List.generate(
              part.params.length,
              (index) => part.params[index].isMajor ? part.params[index].param : r"$param",
            ),
          ])
      .join("/");

  @override
  void add(HttpRoutePart httpRoutePart) => _httpRouteParts.add(httpRoutePart);

  @override
  void guilds({String? id}) => add(HttpRoutePart("guilds", [if (id != null) HttpRouteParam(id, isMajor: true)]));

  @override
  void channels({String? id}) => add(HttpRoutePart("channels", [if (id != null) HttpRouteParam(id, isMajor: true)]));

  @override
  void webhooks({String? id, String? token}) => _httpRouteParts.add(HttpRoutePart("webhooks", [
        if (id != null) HttpRouteParam(id, isMajor: token != null),
        if (token != null) HttpRouteParam(token, isMajor: id != null),
      ]));

  @override
  void reactions({String? emoji, String? userId}) => add(HttpRoutePart("reactions", [
        if (emoji != null) HttpRouteParam(emoji),
        if (userId != null) HttpRouteParam(userId),
      ]));

  @override
  void emojis({String? id}) => add(HttpRoutePart("emojis", [if (id != null) HttpRouteParam(id)]));

  @override
  void roles({String? id}) => add(HttpRoutePart("roles", [if (id != null) HttpRouteParam(id)]));

  @override
  void members({String? id}) => add(HttpRoutePart("members", [if (id != null) HttpRouteParam(id)]));

  @override
  void bans({String? id}) => add(HttpRoutePart("bans", [if (id != null) HttpRouteParam(id)]));

  @override
  void users({String? id}) => add(HttpRoutePart("users", [if (id != null) HttpRouteParam(id)]));

  @override
  void permissions({String? id}) => add(HttpRoutePart("permissions", [if (id != null) HttpRouteParam(id)]));

  @override
  void messages({String? id}) => add(HttpRoutePart("messages", [if (id != null) HttpRouteParam(id)]));

  @override
  void pins({String? id}) => add(HttpRoutePart("pins", [if (id != null) HttpRouteParam(id)]));

  @override
  void invites({String? id}) => add(HttpRoutePart("invites", [if (id != null) HttpRouteParam(id)]));

  @override
  void applications({String? id}) => add(HttpRoutePart("applications", [if (id != null) HttpRouteParam(id)]));

  @override
  void stageinstances({String? id}) => add(HttpRoutePart("stage-instances", [if (id != null) HttpRouteParam(id)]));

  @override
  void threadMembers({String? id}) => add(HttpRoutePart("thread-members", [if (id != null) HttpRouteParam(id)]));

  @override
  void stickers({String? id}) => add(HttpRoutePart("stickers", [if (id != null) HttpRouteParam(id)]));

  @override
  void avatars() => add(HttpRoutePart("avatars"));

  @override
  void scheduledEvents({String? id}) => add(HttpRoutePart("scheduled-events", [if (id != null) HttpRouteParam(id)]));

  @override
  void prune() => add(HttpRoutePart("prune"));

  @override
  void nick() => add(HttpRoutePart("nick"));

  @override
  void auditlogs() => add(HttpRoutePart("audit-logs"));

  @override
  void regions() => add(HttpRoutePart("regions"));

  @override
  void search() => add(HttpRoutePart("search"));

  @override
  void bulkdelete() => add(HttpRoutePart("bulk-delete"));

  @override
  void typing() => add(HttpRoutePart("typing"));

  @override
  void crosspost() => add(HttpRoutePart("crosspost"));

  @override
  void threads() => add(HttpRoutePart("threads"));

  @override
  void gateway() => add(HttpRoutePart("gateway"));

  @override
  void bot() => add(HttpRoutePart("bot"));

  @override
  void oauth2() => add(HttpRoutePart("oauth2"));

  @override
  void preview() => add(HttpRoutePart("preview"));

  @override
  void active() => add(HttpRoutePart("active"));

  @override
  void archived() => add(HttpRoutePart("archived"));

  @override
  void private() => add(HttpRoutePart("private"));

  @override
  void public() => add(HttpRoutePart("public"));

  @override
  void stickerpacks() => add(HttpRoutePart("sticker-packs"));

  @override
  void welcomeScreen() => add(HttpRoutePart('welcome-screen'));
}