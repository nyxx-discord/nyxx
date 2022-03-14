import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/audit_logs/audit_log_change.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';

abstract class IAuditLogEntry implements SnowflakeEntity {
  /// Id of the affected entity (webhook, user, role, etc.)
  String get targetId;

  /// Changes made to the target_id
  List<IAuditLogChange> get changes;

  /// The user who made the changes
  Cacheable<Snowflake, IUser> get user;

  /// Type of action that occurred
  AuditLogEntryType get type;

  /// Additional info for certain action types
  String? get options;

  /// The reason for the change
  String? get reason;
}

/// Single entry of Audit Log
///
/// /// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogEntry extends SnowflakeEntity implements IAuditLogEntry {
  /// Id of the affected entity (webhook, user, role, etc.)
  @override
  late final String targetId;

  /// Changes made to the target_id
  @override
  late final List<IAuditLogChange> changes;

  /// The user who made the changes
  @override
  late final Cacheable<Snowflake, IUser> user;

  /// Type of action that occurred
  @override
  late final AuditLogEntryType type;

  /// Additional info for certain action types
  @override
  late final String? options;

  /// The reason for the change
  @override
  late final String? reason;

  /// Creates na instance of [AuditLogEntry]
  AuditLogEntry(RawApiMap raw, INyxx client) : super(Snowflake(raw["id"] as String)) {
    targetId = raw["targetId"] as String;

    changes = [
      if (raw["changes"] != null)
        for (var o in raw["changes"]) AuditLogChange(o as RawApiMap)
    ];

    user = UserCacheable(client, Snowflake(raw["user_id"]));
    type = AuditLogEntryType._create(raw["action_type"] as int);

    options = raw["options"] as String?;

    reason = raw["reason"] as String?;
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
  static const AuditLogEntryType messageBulkDelete = AuditLogEntryType._create(73);
  static const AuditLogEntryType messagePin = AuditLogEntryType._create(74);
  static const AuditLogEntryType messageUnpin = AuditLogEntryType._create(75);
  static const AuditLogEntryType integrationCreate = AuditLogEntryType._create(80);
  static const AuditLogEntryType integrationUpdate = AuditLogEntryType._create(81);
  static const AuditLogEntryType integrationDelete = AuditLogEntryType._create(82);

  const AuditLogEntryType._create(int value) : super(value);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}
