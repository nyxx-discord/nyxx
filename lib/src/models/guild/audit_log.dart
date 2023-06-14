import 'package:nyxx/src/http/managers/audit_log_manager.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class PartialAuditLogEntry extends ManagedSnowflakeEntity<AuditLogEntry> {
  @override
  final AuditLogManager manager;

  PartialAuditLogEntry({required super.id, required this.manager});
}

class AuditLogEntry extends PartialAuditLogEntry {
  final Snowflake? targetId;

  final List<AuditLogChange>? changes;

  final Snowflake? userId;

  final AuditLogEvent actionType;

  final AuditLogEntryInfo? options;

  final String? reason;

  AuditLogEntry({
    required super.id,
    required super.manager,
    required this.targetId,
    required this.changes,
    required this.userId,
    required this.actionType,
    required this.options,
    required this.reason,
  });
}

class AuditLogChange with ToStringHelper {
  final dynamic oldValue;

  final dynamic newValue;

  final String key;

  AuditLogChange({
    required this.oldValue,
    required this.newValue,
    required this.key,
  });
}

enum AuditLogEvent {
  guildUpdate._(1),
  channelCreate._(10),
  channelUpdate._(11),
  channelDelete._(12),
  channelOverwriteCreate._(13),
  channelOverwriteUpdate._(14),
  channelOverwriteDelete._(15),
  memberKick._(20),
  memberPrune._(21),
  memberBanAdd._(22),
  memberBanRemove._(23),
  memberUpdate._(24),
  memberRoleUpdate._(25),
  memberMove._(26),
  memberDisconnect._(27),
  botAdd._(28),
  roleCreate._(30),
  roleUpdate._(31),
  roleDelete._(32),
  inviteCreate._(40),
  inviteUpdate._(41),
  inviteDelete._(42),
  webhookCreate._(50),
  webhookUpdate._(51),
  webhookDelete._(52),
  emojiCreate._(60),
  emojiUpdate._(61),
  emojiDelete._(62),
  messageDelete._(72),
  messageBulkDelete._(73),
  messagePin._(74),
  messageUnpin._(75),
  integrationCreate._(80),
  integrationUpdate._(81),
  integrationDelete._(82),
  stageInstanceCreate._(83),
  stageInstanceUpdate._(84),
  stageInstanceDelete._(85),
  stickerCreate._(90),
  stickerUpdate._(91),
  stickerDelete._(92),
  guildScheduledEventCreate._(100),
  guildScheduledEventUpdate._(101),
  guildScheduledEventDelete._(102),
  threadCreate._(110),
  threadUpdate._(111),
  threadDelete._(112),
  applicationCommandPermissionUpdate._(121),
  autoModerationRuleCreate._(140),
  autoModerationRuleUpdate._(141),
  autoModerationRuleDelete._(142),
  autoModerationBlockMessage._(143),
  autoModerationFlagToChannel._(144),
  autoModerationUserCommunicationDisabled._(145);

  final int value;

  const AuditLogEvent._(this.value);

  factory AuditLogEvent.parse(int value) => AuditLogEvent.values.firstWhere(
        (event) => event.value == value,
        orElse: () => throw FormatException('Unknown audit log event', value),
      );

  @override
  String toString() => 'AuditLogEvent($value)';
}

class AuditLogEntryInfo with ToStringHelper {
  final Snowflake? applicationId;

  final String? autoModerationRuleName;

  final String? autoModerationTriggerType;

  final Snowflake? channelId;

  final String? count;

  final String? deleteMemberDays;

  final Snowflake? id;

  final String? membersRemoved;

  final Snowflake? messageId;

  final String? roleName;

  final PermissionOverwriteType? overwriteType;

  AuditLogEntryInfo({
    required this.applicationId,
    required this.autoModerationRuleName,
    required this.autoModerationTriggerType,
    required this.channelId,
    required this.count,
    required this.deleteMemberDays,
    required this.id,
    required this.membersRemoved,
    required this.messageId,
    required this.roleName,
    required this.overwriteType,
  });
}
