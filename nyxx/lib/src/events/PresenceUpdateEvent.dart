part of nyxx;

/// Sent when a member's presence updates.
class PresenceUpdateEvent {
  /// User object
  late final Cacheable<Snowflake, User> user;

  /// Users current activities
  late final Iterable<Activity> presences;

  /// Status of client
  late final ClientStatus clientStatus;

  PresenceUpdateEvent._new(RawApiMap raw, Nyxx client) {
    this.presences = [
      for (final rawActivity in raw["d"]["activities"])
        Activity._new(rawActivity as RawApiMap)
    ];
    this.clientStatus = ClientStatus._deserialize(raw["d"]["client_status"] as RawApiMap);
    this.user = _UserCacheable(client, Snowflake(raw["d"]["user"]["id"]));

    final user = this.user.getFromCache();
    if (user != null) {
      if (this.clientStatus != user.status) {
        user.status = this.clientStatus;
      }

      // TODO: Decide what to do with multiplace presences
      // user.presence = this.presences.first;
    }
  }
}
