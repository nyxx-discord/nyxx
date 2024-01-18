import 'package:nyxx/src/http/managers/audit_log_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [AuditLogEntry].
class PartialAuditLogEntry extends ManagedSnowflakeEntity<AuditLogEntry> {
  @override
  final AuditLogManager manager;

  /// Create a new [PartialAuditLogEntry].
  /// @nodoc
  PartialAuditLogEntry({required super.id, required this.manager});
}

/// {@template audit_log_entry}
/// An entry in a [Guild]'s audit log.
/// {@endtemplate}
class AuditLogEntry extends PartialAuditLogEntry {
  /// The ID of the targeted entity.
  final Snowflake? targetId;

  /// A list of changes made to the entity.
  final List<AuditLogChange>? changes;

  /// The ID of the user that triggered the action.
  final Snowflake? userId;

  /// The type of action taken.
  final AuditLogEvent actionType;

  /// Additional information associated with this entry.
  final AuditLogEntryInfo? options;

  /// The reason for this action.
  final String? reason;

  /// {@macro audit_log_entry}
  /// @nodoc
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

  /// The user that triggered the action.
  PartialUser? get user => userId == null ? null : manager.client.users[userId!];
}

/// {@template audit_log_change}
/// A change to an object's field in an [AuditLogEntry].
/// {@endtemplate}
class AuditLogChange with ToStringHelper {
  /// The old, unparsed value of the field.
  final dynamic oldValue;

  /// The new, unparsed value of the field.
  final dynamic newValue;

  /// The name of the affected field.
  final String key;

  /// {@macro audit_log_change}
  /// @nodoc
  AuditLogChange({
    required this.oldValue,
    required this.newValue,
    required this.key,
  });
}

/// The type of event an [AuditLogEntry] represents.
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
  autoModerationUserCommunicationDisabled._(145),
  creatorMonetizationRequestCreated._(150),
  creatorMonetizationTermsAccepted._(151);

  /// The value of this [AuditLogEvent].
  final int value;

  const AuditLogEvent._(this.value);

  /// Parse an [AuditLogEvent] from an [int].
  ///
  /// The [value] must be a valid audit log event.
  factory AuditLogEvent.parse(int value) => AuditLogEvent.values.firstWhere(
        (event) => event.value == value,
        orElse: () => throw FormatException('Unknown audit log event', value),
      );

  @override
  String toString() => 'AuditLogEvent($value)';
}

/// {@template audit_log_entry_info}
/// Extra information associated with an [AuditLogEntry].
/// {@endtemplate}
class AuditLogEntryInfo with ToStringHelper {
  /// The manager for this [AuditLogEntryInfo].
  final AuditLogManager manager;

  /// The ID of the application whose permissions were targeted.
  final Snowflake? applicationId;

  /// The name of the Auto Moderation rule that was triggered.
  final String? autoModerationRuleName;

  /// The trigger type of the Auto Moderation rule that was triggered.
  final String? autoModerationTriggerType;

  /// The ID of the channel in which entities were targeted.
  final Snowflake? channelId;

  /// The number of targeted entities.
  final String? count;

  /// The number of days after which inactive members were kicked.
  final String? deleteMemberDays;

  /// The ID of the overwritten entity.
  final Snowflake? id;

  /// The number of members removed by a prune.
  final String? membersRemoved;

  /// The ID of the targeted message.
  final Snowflake? messageId;

  /// The name of the role.
  final String? roleName;

  // The type of overwrite that was targeted.
  final PermissionOverwriteType? overwriteType;

  /// The type of integration that performed the action.
  final String? integrationType;

  /// {@macro audit_log_entry_info}
  /// @nodoc
  AuditLogEntryInfo({
    required this.manager,
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
    required this.integrationType,
  });

  /// The application whose permissions were targeted.
  PartialApplication? get application => applicationId == null ? null : manager.client.applications[applicationId!];

  /// The channel in which entities were targeted.
  PartialChannel? get channel => channelId == null ? null : manager.client.channels[channelId!];

  /// The targeted message.
  PartialMessage? get message => messageId == null ? null : (channel as PartialTextChannel?)?.messages[messageId!];
}
