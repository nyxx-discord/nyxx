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
  Iterable<AuditLogEntry> filterByUsers(List<User> users) =>
    entries.values.where((entry) => users.contains(entry.user));

  /// Filter audit log entries by type of change
  Iterable<AuditLogEntry> filterByChangeType(List<ChangeKeyType> changeType) =>
    entries.values.where((entry) => entry.changes.any((t) => changeType.contains(t.key)));

  /// Filter audit log by type of entry
  Iterable<AuditLogEntry> filterByEntryType(List<AuditLogEntryType> entryType) =>
    entries.values.where((entry) => entryType.contains(entry.type));

  /// Filter audit log by id of target
  Iterable<AuditLogEntry> filterByTargetId(List<Snowflake> targetId) =>
    entries.values.where((entry) => targetId.contains(entry.targetId));

  AuditLog._new(Map<String, dynamic> raw, Nyxx client) {
    webhooks = {};
    users = {};
    entries = {};

    raw["webhooks"].forEach((o) {
      webhooks[Snowflake(o["id"] as String)] = Webhook._new(o as Map<String, dynamic>, client);
    });

    raw["users"].forEach((o) {
      users[Snowflake(o["id"] as String)] = User._new(o as Map<String, dynamic>, client);
    });

    raw["audit_log_entries"].forEach((o) {
      entries[Snowflake(o["id"] as String)] = AuditLogEntry._new(o as Map<String, dynamic>, client);
    });
  }
}
