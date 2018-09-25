part of nyxx;

/// Whenever an admin action is performed on the API, an entry is added to the respective guild's audit log.
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLog {
  /// List of webhooks found in the audit log
  Map<Snowflake, Webhook> webhooks;

  /// List of users found in the audit log
  Map<Snowflake, User> users;

  /// List of audit log entries
  Map<Snowflake, AuditLogEntry> entries;

  AuditLog._new(Map<String, dynamic> raw) {
    webhooks = Map();
    users = Map();
    entries = Map();

    raw['webhooks'].forEach((o) {
      webhooks[Snowflake(o['id'] as String)] =
          Webhook._new(o as Map<String, dynamic>);
    });

    raw['users'].forEach((o) {
      users[Snowflake(o['id'] as String)] =
          User._new(o as Map<String, dynamic>);
    });

    raw['audit_log_entries'].forEach((o) {
      entries[Snowflake(o['id'] as String)] =
          AuditLogEntry._new(o as Map<String, dynamic>);
    });
  }
}
