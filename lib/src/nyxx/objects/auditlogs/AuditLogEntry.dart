part of nyxx;

/// Single entry of Audit Log
///
/// /// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogEntry extends SnowflakeEntity {
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

  AuditLogEntry._new(Client client, this.raw) : super(new Snowflake(raw['id'] as String)) {
    targetId = raw['targetId'] as String;

    changes = new List();
    if (raw['changes'] != null)
      raw['changes'].forEach(
          (Map<String, dynamic> o) => changes.add(new AuditLogChange._new(o)));

    user = client.users[new Snowflake(raw['user_id'] as String)];
    type = raw['action_type'] as int;
    if (raw['options'] != null) options = raw['options'];
    reason = raw['reason'] as String;
  }
}
