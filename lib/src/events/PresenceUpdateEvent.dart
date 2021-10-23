import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/guild/Status.dart';
import 'package:nyxx/src/core/user/Presence.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
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
    this.presences = [for (final rawActivity in raw["d"]["activities"]) Activity(rawActivity as RawApiMap)];
    this.clientStatus = ClientStatus(raw["d"]["client_status"] as RawApiMap);
    this.user = UserCacheable(client, Snowflake(raw["d"]["user"]["id"]));

    final user = this.user.getFromCache();
    if (user != null) {
      if (this.clientStatus != user.status) {
        (user as User).status = this.clientStatus;
      }

      // TODO: Decide what to do with multiplace presences
      // user.presence = this.presences.first;
    }
  }
}
