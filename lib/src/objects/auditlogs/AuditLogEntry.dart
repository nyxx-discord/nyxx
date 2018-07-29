part of nyxx;

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