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
  late final Cacheable<Snowflake, User> user;

  /// Type of action that occurred
  late final AuditLogEntryType type;

  /// Additional info for certain action types
  String? options;

  /// The reason for the change
  String? reason;

  AuditLogEntry._new(Map<String, dynamic> raw, Nyxx client) : super(Snowflake(raw["id"] as String)) {
    this.targetId = raw["targetId"] as String;

    this.changes = [
      if (raw["changes"] != null)
        for (var o in raw["changes"]) AuditLogChange._new(o as Map<String, dynamic>)
    ];

    this.user = _UserCacheable(client, Snowflake(raw["user_id"]));
    this.type = AuditLogEntryType._create(raw["action_type"] as int);

    if (raw["options"] != null) {
      this.options = raw["options"] as String;
    }

    this.reason = raw["reason"] as String;
  }
}

class AuditLogEntryType extends IEnum<int> {
  static const AuditLogEntryType guildUpdate = AuditLogEntryType._create(1);
  static const AuditLogEntryType channelCreate = AuditLogEntryType._create(10);
  static const AuditLogEntryType channelUpdate = AuditLogEntryType._create(11);
  static const AuditLogEntryType channelDelete = AuditLogEntryType._create(12);
  static const AuditLogEntryType channelOverwriteCreate = AuditLogEntryType._create(13);
  static const AuditLogEntryType channelOverwriteUpdate = AuditLogEntryType._create(14);
  static const AuditLogEntryType channelOverwriteDelete = AuditLogEntryType._create(15);
  static const AuditLogEntryType memberKick = AuditLogEntryType._create(20);
  static const AuditLogEntryType memberPrune = AuditLogEntryType._create(21);
  static const AuditLogEntryType memberBanAdd = AuditLogEntryType._create(22);
  static const AuditLogEntryType memberBanRemove = AuditLogEntryType._create(23);
  static const AuditLogEntryType memberUpdate = AuditLogEntryType._create(24);
  static const AuditLogEntryType memberRoleUpdate = AuditLogEntryType._create(25);
  static const AuditLogEntryType roleCreate = AuditLogEntryType._create(30);
  static const AuditLogEntryType roleUpdate = AuditLogEntryType._create(31);
  static const AuditLogEntryType roleDelete = AuditLogEntryType._create(32);
  static const AuditLogEntryType inviteCreate = AuditLogEntryType._create(40);
  static const AuditLogEntryType inviteUpdate = AuditLogEntryType._create(41);
  static const AuditLogEntryType inviteDelete = AuditLogEntryType._create(42);
  static const AuditLogEntryType webhookCreate = AuditLogEntryType._create(50);
  static const AuditLogEntryType webhookUpdate = AuditLogEntryType._create(51);
  static const AuditLogEntryType webhookDelete = AuditLogEntryType._create(52);
  static const AuditLogEntryType emojiCreate = AuditLogEntryType._create(60);
  static const AuditLogEntryType emojiUpdate = AuditLogEntryType._create(61);
  static const AuditLogEntryType emojiDelete = AuditLogEntryType._create(62);
  static const AuditLogEntryType messageDelete = AuditLogEntryType._create(72);

  const AuditLogEntryType._create(int value) : super(value);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == this._value;
    }

    return super == other;
  }
}
