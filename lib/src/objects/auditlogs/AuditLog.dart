part of nyxx;

/// Represents [Guild]s audit log.
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLog {
  Client client;

  /// List of webhooks found in the audit log
  Map<String, Webhook> webhooks;

  /// List of users found in the audit log
  Map<String, User> users;

  /// List of audit log entires
  Map<String, AuditLogEntry> entries;

  Map<String, dynamic> raw;

  AuditLog._new(Client client, this.raw) {
    webhooks = new Map();
    users = new Map();
    entries = new Map();

    raw['webhooks'].forEach((Map<String, dynamic> o) {
      webhooks[o['id']] = new Webhook._fromApi(client, o);
    });

    raw['users'].forEach((Map<String, dynamic> o) {
      users[o['id']] = new User._new(client, o);
    });

    raw['audit_log_entries'].forEach((Map<String, dynamic> o) {
      entries[o['id']] = new AuditLogEntry._new(client, o);
    });
  }
}
