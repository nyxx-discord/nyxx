part of nyxx;

/// Single entry of Audit Log
///
/// /// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogEntry extends SnowflakeEntity {
  /// Id of the affected entity (webhook, user, role, etc.)
  late final String targetId;

  /// Changes made to the target_id
  late final List<AuditLogChange> changes;

  /// The user who made the changes
  User? user;

  /// Type of action that occurred
  late final AuditLogEntryType type;

  /// Additional info for certain action types
  String? options;

  /// The reason for the change
  String? reason;

  AuditLogEntry._new(Map<String, dynamic> raw, Nyxx client) : super(Snowflake(raw["id"] as String)) {
    targetId = raw["targetId"] as String;

    changes = [
      if (raw["changes"] != null)
        for (var o in raw["changes"]) AuditLogChange._new(o as Map<String, dynamic>)
    ];

    user = client.users[Snowflake(raw["user_id"])];
    type = AuditLogEntryType(raw["action_type"] as int);

    if (raw["options"] != null) {
      options = raw["options"] as String;
    }

    reason = raw["reason"] as String;
  }
}

class AuditLogEntryType extends IEnum<int> {
  static const AuditLogEntryType guildUpdate = AuditLogEntryType._of(1);
  static const AuditLogEntryType channelCreate = AuditLogEntryType._of(10);
  static const AuditLogEntryType channelUpdate = AuditLogEntryType._of(11);
  static const AuditLogEntryType channelDelete = AuditLogEntryType._of(12);
  static const AuditLogEntryType channelOverwriteCreate = AuditLogEntryType._of(13);
  static const AuditLogEntryType channelOverwriteUpdate = AuditLogEntryType._of(14);
  static const AuditLogEntryType channelOverwriteDelete = AuditLogEntryType._of(15);
  static const AuditLogEntryType memberKick = AuditLogEntryType._of(20);
  static const AuditLogEntryType memberPrune = AuditLogEntryType._of(21);
  static const AuditLogEntryType memberBanAdd = AuditLogEntryType._of(22);
  static const AuditLogEntryType memberBanRemove = AuditLogEntryType._of(23);
  static const AuditLogEntryType memberUpdate = AuditLogEntryType._of(24);
  static const AuditLogEntryType memberRoleUpdate = AuditLogEntryType._of(25);
  static const AuditLogEntryType roleCreate = AuditLogEntryType._of(30);
  static const AuditLogEntryType roleUpdate = AuditLogEntryType._of(31);
  static const AuditLogEntryType roleDelete = AuditLogEntryType._of(32);
  static const AuditLogEntryType inviteCreate = AuditLogEntryType._of(40);
  static const AuditLogEntryType inviteUpdate = AuditLogEntryType._of(41);
  static const AuditLogEntryType inviteDelete = AuditLogEntryType._of(42);
  static const AuditLogEntryType webhookCreate = AuditLogEntryType._of(50);
  static const AuditLogEntryType webhookUpdate = AuditLogEntryType._of(51);
  static const AuditLogEntryType webhookDelete = AuditLogEntryType._of(52);
  static const AuditLogEntryType emojiCreate = AuditLogEntryType._of(60);
  static const AuditLogEntryType emojiUpdate = AuditLogEntryType._of(61);
  static const AuditLogEntryType emojiDelete = AuditLogEntryType._of(62);
  static const AuditLogEntryType messageDelete = AuditLogEntryType._of(72);

  const AuditLogEntryType._of(int value) : super(value);
  AuditLogEntryType(int value) : super(value);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == this._value;
    }

    return super == other;
  }
}
