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
class HttpRoute {
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

  void add(HttpRoutePart httpRoutePart) => _httpRouteParts.add(httpRoutePart);

  void guilds({String? id}) => add(HttpRoutePart("guilds", [if (id != null) HttpRouteParam(id, isMajor: true)]));

  void channels({String? id}) => add(HttpRoutePart("channels", [if (id != null) HttpRouteParam(id, isMajor: true)]));

  void webhooks({String? id, String? token}) => _httpRouteParts.add(HttpRoutePart("webhooks", [
        if (id != null) HttpRouteParam(id, isMajor: token != null),
        if (token != null) HttpRouteParam(token, isMajor: id != null),
      ]));

  void reactions({String? emoji, String? userId}) => add(HttpRoutePart("reactions", [
        if (emoji != null) HttpRouteParam(emoji),
        if (userId != null) HttpRouteParam(userId),
      ]));

  void emojis({String? id}) => add(HttpRoutePart("emojis", [if (id != null) HttpRouteParam(id)]));

  void roles({String? id}) => add(HttpRoutePart("roles", [if (id != null) HttpRouteParam(id)]));

  void members({String? id}) => add(HttpRoutePart("members", [if (id != null) HttpRouteParam(id)]));

  void bans({String? id}) => add(HttpRoutePart("bans", [if (id != null) HttpRouteParam(id)]));

  void users({String? id}) => add(HttpRoutePart("users", [if (id != null) HttpRouteParam(id)]));

  void permissions({String? id}) => add(HttpRoutePart("permissions", [if (id != null) HttpRouteParam(id)]));

  void messages({String? id}) => add(HttpRoutePart("messages", [if (id != null) HttpRouteParam(id)]));

  void pins({String? id}) => add(HttpRoutePart("pins", [if (id != null) HttpRouteParam(id)]));

  void invites({String? id}) => add(HttpRoutePart("invites", [if (id != null) HttpRouteParam(id)]));

  void applications({String? id}) => add(HttpRoutePart("applications", [if (id != null) HttpRouteParam(id)]));

  void stageinstances({String? id}) => add(HttpRoutePart("stage-instances", [if (id != null) HttpRouteParam(id)]));

  void threadMembers({String? id}) => add(HttpRoutePart("thread-members", [if (id != null) HttpRouteParam(id)]));

  void stickers({String? id}) => add(HttpRoutePart("stickers", [if (id != null) HttpRouteParam(id)]));

  void avatars() => add(HttpRoutePart("avatars"));

  void scheduledEvents({String? id}) => add(HttpRoutePart("scheduled-events", [if (id != null) HttpRouteParam(id)]));

  void prune() => add(HttpRoutePart("prune"));

  void nick() => add(HttpRoutePart("nick"));

  void auditlogs() => add(HttpRoutePart("audit-logs"));

  void regions() => add(HttpRoutePart("regions"));

  void search() => add(HttpRoutePart("search"));

  void bulkdelete() => add(HttpRoutePart("bulk-delete"));

  void typing() => add(HttpRoutePart("typing"));

  void crosspost() => add(HttpRoutePart("crosspost"));

  void threads() => add(HttpRoutePart("threads"));

  void gateway() => add(HttpRoutePart("gateway"));

  void bot() => add(HttpRoutePart("bot"));

  void oauth2() => add(HttpRoutePart("oauth2"));

  void preview() => add(HttpRoutePart("preview"));

  void active() => add(HttpRoutePart("active"));

  void archived() => add(HttpRoutePart("archived"));

  void private() => add(HttpRoutePart("private"));

  void public() => add(HttpRoutePart("public"));

  void stickerpacks() => add(HttpRoutePart("sticker-packs"));
}
