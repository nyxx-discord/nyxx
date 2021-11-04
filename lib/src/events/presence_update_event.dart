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
  Iterable<Activity> get presences;

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
  late final Iterable<Activity> presences;

  /// Status of client
  @override
  late final IClientStatus clientStatus;

  /// Creates na instance of [PresenceUpdateEvent]
  PresenceUpdateEvent(RawApiMap raw, INyxx client) {
    presences = [for (final rawActivity in raw["d"]["activities"]) Activity(rawActivity as RawApiMap)];
    clientStatus = ClientStatus(raw["d"]["client_status"] as RawApiMap);
    this.user = UserCacheable(client, Snowflake(raw["d"]["user"]["id"]));

    final user = this.user.getFromCache();
    if (user != null) {
      if (clientStatus != user.status) {
        (user as User).status = clientStatus;
      }

      // TODO: Decide what to do with multiplace presences
      // user.presence = this.presences.first;
    }
  }
}
