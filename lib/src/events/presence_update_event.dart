import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/guild/status.dart';
import 'package:nyxx/src/core/user/presence.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IPresenceUpdateEvent {
  /// User object
  Cacheable<Snowflake, IUser> get user;

  /// Users current activities
  Iterable<IActivity> get presences;

  /// Status of client
  IClientStatus get clientStatus;
}

/// Sent when a member's presence updates.
class PresenceUpdateEvent implements IPresenceUpdateEvent {
  /// User object
  @override
  late final Cacheable<Snowflake, IUser> user;

  /// Users current activities
  @override
  late final Iterable<IActivity> presences;

  /// Status of client
  @override
  late final IClientStatus clientStatus;

  /// Creates an instance of [PresenceUpdateEvent]
  PresenceUpdateEvent(RawApiMap raw, INyxx client) {
    presences = [for (final rawActivity in raw["d"]["activities"]) Activity(rawActivity as RawApiMap, client)];
    clientStatus = ClientStatus(raw["d"]["client_status"] as RawApiMap);
    user = UserCacheable(client, Snowflake(raw["d"]["user"]["id"]));

    final cachedUser = user.getFromCache();
    if (cachedUser != null) {
      if (clientStatus != cachedUser.status) {
        (cachedUser as User).status = clientStatus;
      }

      (cachedUser as User).presence = presences.isNotEmpty ? presences.first : null;
    }
  }
}
