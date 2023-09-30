import 'dart:collection';

/// A route within the Discord API.
///
/// {@template http_route}
/// The path of a request made to the API is encoded as a [HttpRoute]. This allows for anticipation
/// of rate limits based on the request's route.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/topics/rate-limits#rate-limits
/// {@endtemplate}
class HttpRoute {
  final List<HttpRoutePart> _parts = [];

  /// The [HttpRoutePart]s that make up this route.
  List<HttpRoutePart> get parts => UnmodifiableListView(_parts);

  /// The segments of this route.
  ///
  /// This includes the names and parameters of this [parts].
  Iterable<String> get segments => parts.expand((part) => part.segments);

  /// The path this [HttpRoute] represents, relative to Discord's root API URL.
  String get path => '/${segments.join('/')}';

  /// An id used for rate limiting.
  ///
  /// Requests wit the same [HttpRoute.rateLimitId] are put in the same [HttpBucket] for
  /// ratelimiting.
  String get rateLimitId => parts
      .expand((part) => [
            part.name,
            ...part.params.map((param) => param.isMajor ? param.value : r'$param'),
          ])
      .join('/');

  /// Add [part] to this route.
  void add(HttpRoutePart part) => _parts.add(part);

  @override
  String toString() => path;
}

/// A part of a [HttpRoute].
///
/// {@template http_route_part}
/// HTTP route parts are made up of an identifier (such as `/users`) and, optionally, one or more
/// parameters (such as the id of a user).
/// {@endtemplate}
class HttpRoutePart {
  /// The name of this part.
  final String name;

  /// The parameters of this part.
  final List<HttpRouteParam> params;

  /// The segments of this part.
  ///
  /// This includes this part's name and parameter values.
  List<String> get segments => [name, ...params.map((param) => param.value)];

  /// Create a new [HttpRoutePart].
  ///
  /// {@macro http_route_part}
  HttpRoutePart(this.name, [this.params = const []]);
}

/// A parameter in a [HttpRoutePart].
///
/// {@template http_route_part}
/// This is not a query parameter, it is a parameter encoded in the path of the request itself, such
/// as the id of a guild in `/guilds/0123456789`.
/// {@endtemplate}
class HttpRouteParam {
  /// The value of this parameter.
  final String value;

  /// Whether this parameter is a major parameter.
  ///
  /// Major parameters will be included in the [HttpRoute.rateLimitId], so requests to the same
  /// endpoint but different major parameters will be in separate rate limit buckets.
  final bool isMajor;

  /// Create a new [HttpRouteParam].
  ///
  /// {@macro http_route_param}
  HttpRouteParam(this.value, {this.isMajor = false});
}

/// Helper methods for constructing [HttpRoute]s.
extension RouteHelpers on HttpRoute {
  /// Adds the [`guilds`](https://discord.com/developers/docs/resources/guild#get-guild) part to this [HttpRoute].
  void guilds({String? id}) => add(HttpRoutePart("guilds", [if (id != null) HttpRouteParam(id, isMajor: true)]));

  /// Adds the [`channels`](https://discord.com/developers/docs/resources/channel#get-channel) part to this [HttpRoute].
  void channels({String? id}) => add(HttpRoutePart("channels", [if (id != null) HttpRouteParam(id, isMajor: true)]));

  /// Adds the [`webhooks`](https://discord.com/developers/docs/resources/webhook#get-webhook) part to this [HttpRoute].
  void webhooks({String? id, String? token}) => add(HttpRoutePart("webhooks", [
        if (id != null) HttpRouteParam(id, isMajor: token != null),
        if (token != null) HttpRouteParam(token, isMajor: id != null),
      ]));

  /// Adds the [`reactions`](https://discord.com/developers/docs/resources/channel#get-reactions) part to this [HttpRoute].
  void reactions({String? emoji, String? userId}) => add(HttpRoutePart("reactions", [
        if (emoji != null) HttpRouteParam(emoji),
        if (userId != null) HttpRouteParam(userId),
      ]));

  /// Adds the [`emojis`](https://discord.com/developers/docs/resources/emoji#get-guild-emoji) part to this [HttpRoute].
  void emojis({String? id}) => add(HttpRoutePart("emojis", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`roles`](https://discord.com/developers/docs/resources/guild#get-guild-roles) part to this [HttpRoute].
  void roles({String? id}) => add(HttpRoutePart("roles", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`members`](https://discord.com/developers/docs/resources/guild#get-guild-member) part to this [HttpRoute].
  void members({String? id}) => add(HttpRoutePart("members", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`bans`](https://discord.com/developers/docs/resources/guild#get-guild-bans) part to this [HttpRoute].
  void bans({String? id}) => add(HttpRoutePart("bans", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`users`](https://discord.com/developers/docs/resources/user#get-user) part to this [HttpRoute].
  void users({String? id}) => add(HttpRoutePart("users", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`permissions`](https://discord.com/developers/docs/interactions/application-commands#get-guild-application-command-permissions) part to this [HttpRoute].
  void permissions({String? id}) => add(HttpRoutePart("permissions", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`messages`](https://discord.com/developers/docs/resources/channel#get-channel-messages) part to this [HttpRoute].
  void messages({String? id}) => add(HttpRoutePart("messages", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`pins`](https://discord.com/developers/docs/resources/channel#get-pinned-messages) part to this [HttpRoute].
  void pins({String? id}) => add(HttpRoutePart("pins", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`invites`](https://discord.com/developers/docs/resources/guild#get-guild-invites) part to this [HttpRoute].
  void invites({String? id}) => add(HttpRoutePart("invites", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`applications`](https://discord.com/developers/docs/topics/oauth2#get-current-bot-application-information) part to this [HttpRoute].
  void applications({String? id}) => add(HttpRoutePart("applications", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`stage-instances`](https://discord.com/developers/docs/resources/stage-instance#get-stage-instance) part to this [HttpRoute].
  void stageInstances({String? id}) => add(HttpRoutePart("stage-instances", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`thread-members`](https://discord.com/developers/docs/resources/channel#get-thread-member) part to this [HttpRoute].
  void threadMembers({String? id}) => add(HttpRoutePart("thread-members", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`stickers`](https://discord.com/developers/docs/resources/sticker#get-sticker) part to this [HttpRoute].
  void stickers({String? id}) => add(HttpRoutePart("stickers", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`scheduled-events`](https://discord.com/developers/docs/resources/guild-scheduled-event#get-guild-scheduled-event) part to this [HttpRoute].
  void scheduledEvents({String? id}) => add(HttpRoutePart("scheduled-events", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`rules`](https://discord.com/developers/docs/resources/auto-moderation#get-auto-moderation-rule) part to this [HttpRoute].
  void rules({String? id}) => add(HttpRoutePart('rules', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`prune`](https://discord.com/developers/docs/resources/guild#get-guild-prune-count) part to this [HttpRoute].
  void prune() => add(HttpRoutePart("prune"));

  /// Adds the [`nick`](https://discord.com/developers/docs/resources/guild#modify-current-user-nick) part to this [HttpRoute].
  void nick() => add(HttpRoutePart("nick"));

  /// Adds the [`audit-logs`](https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log) part to this [HttpRoute].
  void auditLogs() => add(HttpRoutePart("audit-logs"));

  /// Adds the [`regions`](https://discord.com/developers/docs/resources/voice#list-voice-regions) part to this [HttpRoute].
  void regions() => add(HttpRoutePart("regions"));

  /// Adds the [`search`](https://discord.com/developers/docs/resources/guild#search-guild-members) part to this [HttpRoute].
  void search() => add(HttpRoutePart("search"));

  /// Adds the [`bulk-delete`](https://discord.com/developers/docs/resources/channel#bulk-delete-messages) part to this [HttpRoute].
  void bulkDelete() => add(HttpRoutePart("bulk-delete"));

  /// Adds the [`typing`](https://discord.com/developers/docs/resources/channel#trigger-typing-indicator) part to this [HttpRoute].
  void typing() => add(HttpRoutePart("typing"));

  /// Adds the [`crosspost`](https://discord.com/developers/docs/resources/channel#crosspost-message) part to this [HttpRoute].
  void crosspost() => add(HttpRoutePart("crosspost"));

  /// Adds the [`threads`](https://discord.com/developers/docs/resources/channel#start-thread-from-message) part to this [HttpRoute].
  void threads() => add(HttpRoutePart("threads"));

  /// Adds the [`gateway`](https://discord.com/developers/docs/topics/gateway#get-gateway) part to this [HttpRoute].
  void gateway() => add(HttpRoutePart("gateway"));

  /// Adds the [`bot`](https://discord.com/developers/docs/topics/gateway#get-gateway-bot) part to this [HttpRoute].
  void bot() => add(HttpRoutePart("bot"));

  /// Adds the [`oauth2`](https://discord.com/developers/docs/topics/oauth2#get-current-authorization-information) part to this [HttpRoute].
  void oauth2() => add(HttpRoutePart("oauth2"));

  /// Adds the [`preview`](https://discord.com/developers/docs/resources/guild#get-guild-preview) part to this [HttpRoute].
  void preview() => add(HttpRoutePart("preview"));

  /// Adds the [`active`](https://discord.com/developers/docs/resources/guild#list-active-guild-threads) part to this [HttpRoute].
  void active() => add(HttpRoutePart("active"));

  /// Adds the [`archived`](https://discord.com/developers/docs/resources/channel#list-public-archived-threads) part to this [HttpRoute].
  void archived() => add(HttpRoutePart("archived"));

  /// Adds the [`private`](https://discord.com/developers/docs/resources/channel#list-private-archived-threads) part to this [HttpRoute].
  void private() => add(HttpRoutePart("private"));

  /// Adds the [`public`](https://discord.com/developers/docs/resources/channel#list-public-archived-threads) part to this [HttpRoute].
  void public() => add(HttpRoutePart("public"));

  /// Adds the [`sticker-packs`](https://discord.com/developers/docs/resources/sticker#list-nitro-sticker-packs) part to this [HttpRoute].
  void stickerPacks({String? id}) => add(HttpRoutePart("sticker-packs", [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`welcome-screen`](https://discord.com/developers/docs/resources/guild#get-guild-welcome-screen) part to this [HttpRoute].
  void welcomeScreen() => add(HttpRoutePart('welcome-screen'));

  /// Adds the [`auto-moderation`](https://discord.com/developers/docs/resources/auto-moderation#list-auto-moderation-rules-for-guild) part to this [HttpRoute].
  void autoModeration() => add(HttpRoutePart('auto-moderation'));

  /// Adds the [`connections`](https://discord.com/developers/docs/resources/user#get-user-connections) part to this [HttpRoute].
  void connections() => add(HttpRoutePart('connections'));

  /// Adds the [`followers`](https://discord.com/developers/docs/resources/channel#follow-announcement-channel) part to this [HttpRoute].
  void followers() => add(HttpRoutePart('followers'));

  /// Adds the [`mfa`](https://discord.com/developers/docs/resources/guild#modify-guild-mfa-level) part to this [HttpRoute].
  void mfa() => add(HttpRoutePart('mfa'));

  /// Adds the [`voice`](https://discord.com/developers/docs/resources/voice#list-voice-regions) part to this [HttpRoute].
  void voice() => add(HttpRoutePart('voice'));

  /// Adds the [`integrations`](https://discord.com/developers/docs/resources/guild#get-guild-integrations) part to this [HttpRoute].
  void integrations({String? id}) => add(HttpRoutePart('integrations', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`widget`](https://discord.com/developers/docs/resources/guild#get-guild-widget-settings) part to this [HttpRoute].
  void widget() => add(HttpRoutePart('widget'));

  /// Adds the [`widget.json`](https://discord.com/developers/docs/resources/guild#get-guild-widget) part to this [HttpRoute].
  void widgetJson() => add(HttpRoutePart('widget.json'));

  /// Adds the [`widget.png`](https://discord.com/developers/docs/resources/guild#get-guild-widget-image) part to this [HttpRoute].
  void widgetPng() => add(HttpRoutePart('widget.png'));

  /// Adds the [`onboarding`](https://discord.com/developers/docs/resources/guild#get-guild-onboarding) part to this [HttpRoute].
  void onboarding() => add(HttpRoutePart('onboarding'));

  /// Adds the [`voice-states`](https://discord.com/developers/docs/resources/guild#modify-current-user-voice-state) part to this [HttpRoute].
  void voiceStates({String? id}) => add(HttpRoutePart('voice-states', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`role-connections`](https://discord.com/developers/docs/resources/application-role-connection-metadata#get-application-role-connection-metadata-records)
  /// part to this [HttpRoute].
  void roleConnections() => add(HttpRoutePart('role-connections'));

  /// Adds the [`metadata`](https://discord.com/developers/docs/resources/application-role-connection-metadata#get-application-role-connection-metadata-records)
  /// part to this [HttpRoute].
  void metadata() => add(HttpRoutePart('metadata'));

  /// Adds the [`templates`](https://discord.com/developers/docs/resources/guild-template#get-guild-template) part to this [HttpRoute].
  void templates({String? code}) => add(HttpRoutePart('templates', [if (code != null) HttpRouteParam(code)]));

  /// Adds the [`role-connection`](https://discord.com/developers/docs/resources/user#get-user-application-role-connection)
  /// part to this [HttpRoute].
  void roleConnection() => add(HttpRoutePart('role-connection'));

  /// Adds the [`member`](https://discord.com/developers/docs/resources/user#get-current-user-guild-member) part to this [HttpRoute].
  void member() => add(HttpRoutePart("member"));

  /// Adds the [`vanity-url`](https://discord.com/developers/docs/resources/guild#get-guild-vanity-url) part to this [HttpRoute].
  void vanityUrl() => add(HttpRoutePart('vanity-url'));

  /// Adds the [`icons`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void icons({String? id}) => add(HttpRoutePart('icons', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`splashes`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void splashes({String? id}) => add(HttpRoutePart('splashes', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`discovery-splashes`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void discoverySplashes({String? id}) => add(HttpRoutePart('discovery-splashes', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`banners`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void banners({String? id}) => add(HttpRoutePart('banners', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`embed`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void embed({String? id}) => add(HttpRoutePart('embed', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`avatars`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void avatars({String? id}) => add(HttpRoutePart('avatars', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`app-icons`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void appIcons({String? id}) => add(HttpRoutePart('app-icons', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`team-icons`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void teamIcons({String? id}) => add(HttpRoutePart('team-icons', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`role-icons`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void roleIcons({String? id}) => add(HttpRoutePart('role-icons', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`guild-events`](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints) part to this [HttpRoute].
  void guildEvents({String? id}) => add(HttpRoutePart('guild-events', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`commands`](https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands) part to this [HttpRoute].
  void commands({String? id}) => add(HttpRoutePart('commands', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`interactions`](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response) part to this [HttpRoute].
  void interactions({String? id, String? token}) =>
      add(HttpRoutePart('interactions', [if (id != null) HttpRouteParam(id), if (token != null) HttpRouteParam(token)]));

  /// Adds the [`callback`](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response) part to this [HttpRoute].
  void callback() => add(HttpRoutePart('callback'));

  /// Adds the [`entitlements`](https://discord.com/developers/docs/monetization/entitlements#list-entitlements) part to this [HttpRoute].
  void entitlements({String? id}) => add(HttpRoutePart('entitlements', [if (id != null) HttpRouteParam(id)]));

  /// Adds the [`skus`](https://discord.com/developers/docs/monetization/skus#list-skus) part to this [HttpRoute].
  void skus() => add(HttpRoutePart('skus'));
}
