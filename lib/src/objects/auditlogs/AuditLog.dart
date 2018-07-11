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
      webhooks[o['id']] =
          new Webhook._fromApi(client, o as Map<String, dynamic>);
    });

    raw['users'].forEach((Map<String, dynamic> o) {
      users[o['id']] = new User._new(client, o);
    });

    raw['audit_log_entries'].forEach((Map<String, dynamic> o) {
      entries[o['id']] = new AuditLogEntry._new(client, o);
    });
  }
}

/// Single entry of Audit Log
///
/// /// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogEntry {
  /// Id of the affected entity (webhook, user, role, etc.)
  String targetId;

  /// Changes made to the target_id
  List<AuditLogChange> changes;

  /// The user who made the changes
  User user;

  /// Id of the entry
  Snowflake id;

  /// Type of action that occured
  int type;

  /// Additional info for certain action types
  dynamic options;

  /// The reason for the change
  String reason;

  /// Raw data from API
  Map<String, dynamic> raw;

  AuditLogEntry._new(Client client, this.raw) {
    targetId = raw['targetId'];

    changes = new List();
    if (raw['changes'] != null)
      raw['changes'].forEach(
          (Map<String, dynamic> o) => changes.add(new AuditLogChange._new(o)));

    user = client.users[raw['user_id']];
    id = new Snowflake(raw['id']);
    type = raw['action_type'];

    if (raw['options'] != null) options = raw['options'];

    reason = raw['reason'];
  }
}

/// Represents change made in guild with old and new value
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogChange {
  /// New value
  dynamic newValue;

  /// Old value
  dynamic oldValue;

  /// type of audit log change hey
  String key;

  Map<String, dynamic> raw;

  AuditLogChange._new(this.raw) {
    if (raw['new_value'] != null) newValue = raw['new_value'];

    if (raw['old_value'] != null) oldValue = raw['old_value'];

    key = raw['key'];
  }
}
