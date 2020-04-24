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

  Iterable<AuditLogEntry> filterByUsers(List<User> users) {
    return entries.values.where((entry) => users.contains(entry.user));
  }

  Iterable<AuditLogEntry> filterByChangeType(List<ChangeKeyType> changeType) {
    return entries.values.where(
            (entry) => entry.changes.any((t) => changeType.contains(t.key)));
  }

  Iterable<AuditLogEntry> filterByEntryType(List<AuditLogEntryType> entryType) {
    return entries.values.where((entry) => entryType.contains(entry.type));
  }

  Iterable<AuditLogEntry> filterByTargetId(List<Snowflake> targetId) {
    return entries.values.where((entry) => targetId.contains(entry.targetId));
  }

  AuditLog._new(Map<String, dynamic> raw, Nyxx client) {
    webhooks = Map();
    users = Map();
    entries = Map();

    raw['webhooks'].forEach((o) {
      webhooks[Snowflake(o['id'] as String)] =
          Webhook._new(o as Map<String, dynamic>, client);
    });

    raw['users'].forEach((o) {
      users[Snowflake(o['id'] as String)] =
          User._new(o as Map<String, dynamic>, client);
    });

    raw['audit_log_entries'].forEach((o) {
      entries[Snowflake(o['id'] as String)] =
          AuditLogEntry._new(o as Map<String, dynamic>, client);
    });
  }
}
