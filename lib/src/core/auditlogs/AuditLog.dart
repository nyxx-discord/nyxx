part of nyxx;

/// Whenever an admin action is performed on the API, an entry is added to the respective guild's audit log.
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLog {
  /// List of webhooks found in the audit log
  late final Map<Snowflake, Webhook> webhooks;

  /// List of users found in the audit log
  late final Map<Snowflake, User> users;

  /// List of audit log entries
  late final Map<Snowflake, AuditLogEntry> entries;

  /// Filters audit log by [users]
  Iterable<AuditLogEntry> filter(bool Function(AuditLogEntry) test) =>
      entries.values.where(test);

  AuditLog._new(RawApiMap raw, INyxx client) {
    webhooks = {};
    users = {};
    entries = {};

    raw["webhooks"].forEach((o) {
      webhooks[Snowflake(o["id"] as String)] = Webhook._new(o as RawApiMap, client);
    });

    raw["users"].forEach((o) {
      users[Snowflake(o["id"] as String)] = User._new(client, o as RawApiMap);
    });

    raw["audit_log_entries"].forEach((o) {
      entries[Snowflake(o["id"] as String)] = AuditLogEntry._new(o as RawApiMap, client);
    });
  }
}
