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
final class AuditLogEvent extends EnumLike<int> {
  static const guildUpdate = AuditLogEvent._(1);
  static const channelCreate = AuditLogEvent._(10);
  static const channelUpdate = AuditLogEvent._(11);
  static const channelDelete = AuditLogEvent._(12);
  static const channelOverwriteCreate = AuditLogEvent._(13);
  static const channelOverwriteUpdate = AuditLogEvent._(14);
  static const channelOverwriteDelete = AuditLogEvent._(15);
  static const memberKick = AuditLogEvent._(20);
  static const memberPrune = AuditLogEvent._(21);
  static const memberBanAdd = AuditLogEvent._(22);
  static const memberBanRemove = AuditLogEvent._(23);
  static const memberUpdate = AuditLogEvent._(24);
  static const memberRoleUpdate = AuditLogEvent._(25);
  static const memberMove = AuditLogEvent._(26);
  static const memberDisconnect = AuditLogEvent._(27);
  static const botAdd = AuditLogEvent._(28);
  static const roleCreate = AuditLogEvent._(30);
  static const roleUpdate = AuditLogEvent._(31);
  static const roleDelete = AuditLogEvent._(32);
  static const inviteCreate = AuditLogEvent._(40);
  static const inviteUpdate = AuditLogEvent._(41);
  static const inviteDelete = AuditLogEvent._(42);
  static const webhookCreate = AuditLogEvent._(50);
  static const webhookUpdate = AuditLogEvent._(51);
  static const webhookDelete = AuditLogEvent._(52);
  static const emojiCreate = AuditLogEvent._(60);
  static const emojiUpdate = AuditLogEvent._(61);
  static const emojiDelete = AuditLogEvent._(62);
  static const messageDelete = AuditLogEvent._(72);
  static const messageBulkDelete = AuditLogEvent._(73);
  static const messagePin = AuditLogEvent._(74);
  static const messageUnpin = AuditLogEvent._(75);
  static const integrationCreate = AuditLogEvent._(80);
  static const integrationUpdate = AuditLogEvent._(81);
  static const integrationDelete = AuditLogEvent._(82);
  static const stageInstanceCreate = AuditLogEvent._(83);
  static const stageInstanceUpdate = AuditLogEvent._(84);
  static const stageInstanceDelete = AuditLogEvent._(85);
  static const stickerCreate = AuditLogEvent._(90);
  static const stickerUpdate = AuditLogEvent._(91);
  static const stickerDelete = AuditLogEvent._(92);
  static const guildScheduledEventCreate = AuditLogEvent._(100);
  static const guildScheduledEventUpdate = AuditLogEvent._(101);
  static const guildScheduledEventDelete = AuditLogEvent._(102);
  static const threadCreate = AuditLogEvent._(110);
  static const threadUpdate = AuditLogEvent._(111);
  static const threadDelete = AuditLogEvent._(112);
  static const applicationCommandPermissionUpdate = AuditLogEvent._(121);
  static const autoModerationRuleCreate = AuditLogEvent._(140);
  static const autoModerationRuleUpdate = AuditLogEvent._(141);
  static const autoModerationRuleDelete = AuditLogEvent._(142);
  static const autoModerationBlockMessage = AuditLogEvent._(143);
  static const autoModerationFlagToChannel = AuditLogEvent._(144);
  static const autoModerationUserCommunicationDisabled = AuditLogEvent._(145);
  static const creatorMonetizationRequestCreated = AuditLogEvent._(150);
  static const creatorMonetizationTermsAccepted = AuditLogEvent._(151);

  static const values = [
    guildUpdate,
    channelCreate,
    channelUpdate,
    channelDelete,
    channelOverwriteCreate,
    channelOverwriteUpdate,
    channelOverwriteDelete,
    memberKick,
    memberPrune,
    memberBanAdd,
    memberBanRemove,
    memberUpdate,
    memberRoleUpdate,
    memberMove,
    memberDisconnect,
    botAdd,
    roleCreate,
    roleUpdate,
    roleDelete,
    inviteCreate,
    inviteUpdate,
    inviteDelete,
    webhookCreate,
    webhookUpdate,
    webhookDelete,
    emojiCreate,
    emojiUpdate,
    emojiDelete,
    messageDelete,
    messageBulkDelete,
    messagePin,
    messageUnpin,
    integrationCreate,
    integrationUpdate,
    integrationDelete,
    stageInstanceCreate,
    stageInstanceUpdate,
    stageInstanceDelete,
    stickerCreate,
    stickerUpdate,
    stickerDelete,
    guildScheduledEventCreate,
    guildScheduledEventUpdate,
    guildScheduledEventDelete,
    threadCreate,
    threadUpdate,
    threadDelete,
    applicationCommandPermissionUpdate,
    autoModerationRuleCreate,
    autoModerationRuleUpdate,
    autoModerationRuleDelete,
    autoModerationBlockMessage,
    autoModerationFlagToChannel,
    autoModerationUserCommunicationDisabled,
    creatorMonetizationRequestCreated,
    creatorMonetizationTermsAccepted,
  ];

  const AuditLogEvent._(super.value);

  factory AuditLogEvent.parse(int value) => parseEnum(values, value);
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
