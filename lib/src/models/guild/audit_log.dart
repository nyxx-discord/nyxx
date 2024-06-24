import 'package:nyxx/src/http/managers/audit_log_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
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
final class AuditLogEvent extends EnumLike<int, AuditLogEvent> {
  static const guildUpdate = AuditLogEvent(1);
  static const channelCreate = AuditLogEvent(10);
  static const channelUpdate = AuditLogEvent(11);
  static const channelDelete = AuditLogEvent(12);
  static const channelOverwriteCreate = AuditLogEvent(13);
  static const channelOverwriteUpdate = AuditLogEvent(14);
  static const channelOverwriteDelete = AuditLogEvent(15);
  static const memberKick = AuditLogEvent(20);
  static const memberPrune = AuditLogEvent(21);
  static const memberBanAdd = AuditLogEvent(22);
  static const memberBanRemove = AuditLogEvent(23);
  static const memberUpdate = AuditLogEvent(24);
  static const memberRoleUpdate = AuditLogEvent(25);
  static const memberMove = AuditLogEvent(26);
  static const memberDisconnect = AuditLogEvent(27);
  static const botAdd = AuditLogEvent(28);
  static const roleCreate = AuditLogEvent(30);
  static const roleUpdate = AuditLogEvent(31);
  static const roleDelete = AuditLogEvent(32);
  static const inviteCreate = AuditLogEvent(40);
  static const inviteUpdate = AuditLogEvent(41);
  static const inviteDelete = AuditLogEvent(42);
  static const webhookCreate = AuditLogEvent(50);
  static const webhookUpdate = AuditLogEvent(51);
  static const webhookDelete = AuditLogEvent(52);
  static const emojiCreate = AuditLogEvent(60);
  static const emojiUpdate = AuditLogEvent(61);
  static const emojiDelete = AuditLogEvent(62);
  static const messageDelete = AuditLogEvent(72);
  static const messageBulkDelete = AuditLogEvent(73);
  static const messagePin = AuditLogEvent(74);
  static const messageUnpin = AuditLogEvent(75);
  static const integrationCreate = AuditLogEvent(80);
  static const integrationUpdate = AuditLogEvent(81);
  static const integrationDelete = AuditLogEvent(82);
  static const stageInstanceCreate = AuditLogEvent(83);
  static const stageInstanceUpdate = AuditLogEvent(84);
  static const stageInstanceDelete = AuditLogEvent(85);
  static const stickerCreate = AuditLogEvent(90);
  static const stickerUpdate = AuditLogEvent(91);
  static const stickerDelete = AuditLogEvent(92);
  static const guildScheduledEventCreate = AuditLogEvent(100);
  static const guildScheduledEventUpdate = AuditLogEvent(101);
  static const guildScheduledEventDelete = AuditLogEvent(102);
  static const threadCreate = AuditLogEvent(110);
  static const threadUpdate = AuditLogEvent(111);
  static const threadDelete = AuditLogEvent(112);
  static const applicationCommandPermissionUpdate = AuditLogEvent(121);
  static const autoModerationRuleCreate = AuditLogEvent(140);
  static const autoModerationRuleUpdate = AuditLogEvent(141);
  static const autoModerationRuleDelete = AuditLogEvent(142);
  static const autoModerationBlockMessage = AuditLogEvent(143);
  static const autoModerationFlagToChannel = AuditLogEvent(144);
  static const autoModerationUserCommunicationDisabled = AuditLogEvent(145);
  static const creatorMonetizationRequestCreated = AuditLogEvent(150);
  static const creatorMonetizationTermsAccepted = AuditLogEvent(151);

  /// @nodoc
  const AuditLogEvent(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  AuditLogEvent.parse(int value) : this(value);
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
