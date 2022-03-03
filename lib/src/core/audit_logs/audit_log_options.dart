import 'package:nyxx/nyxx.dart';

/// Additionnal info for certain [action types](https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events)
abstract class IAuditLogOptions {
  /// The channel in which the entites were targeted.
  /// 
  /// Shows only in: 
  /// - [AuditLogEntryType.memberMove]; 
  /// - [AuditLogEntryType.messagePin];
  /// - [AuditLogEntryType.messageUnpin];
  /// - [AuditLogEntryType.messageDelete];
  /// - [AuditLogEntryType.stageInstanceCreate];
  /// - [AuditLogEntryType.stageInstanceUpdate] and [AuditLogEntryType.stageInstanceDelete] action types
  Snowflake? get channelId;

  /// The number of entities targeted.
  /// Shows only in: 
  /// - [AuditLogEntryType.messageDelete];
  /// - [AuditLogEntryType.messageBulkDelete];
  /// - [AuditLogEntryType.memberDisconnect] and [AuditLogEntryType.memberMove] action types 
  int? get count;

  /// The number of days after which inactive users will be kicked.
  /// Shows only in: [AuditLogEntryType.memberPrune] action types
  String? get deleteMemberDelay;

  /// Id of the overwritten entity.
  /// Shows only in: 
  /// - [AuditLogEntryType.channelOverwriteCreate];
  /// - [AuditLogEntryType.channelOverwriteUpdate] and [AuditLogEntryType.channelOverwriteDelete] action types
  Snowflake? get id;

  /// The number of the members removed by the prune.
  /// Shows only in: [AuditLogEntryType.memberPrune] action types
  int? get pruneCount;

  /// The id of the message that was targeted.
  /// Shows only in: [AuditLogEntryType.messagePin] and [AuditLogEntryType.messageUnpin] action types
  Snowflake? get messageId;

  /// The name of the role that was targeted. (Not present if [overwrittenType] is `member`).
  /// Shows only in: 
  /// - [AuditLogEntryType.channelOverwriteCreate];
  /// - [AuditLogEntryType.channelOverwriteUpdate] and [AuditLogEntryType.channelOverwriteDelete] action types
  String? get roleName;

  /// Type of overwritten entity.
  /// One of: 
  ///   - `role`
  ///   - `member`
  ///
  /// Shows only in: 
  /// - [AuditLogEntryType.channelOverwriteCreate];
  /// - [AuditLogEntryType.channelOverwriteUpdate] and [AuditLogEntryType.channelOverwriteDelete] action types
  String? get overwrittenType;

  /// The constructor for the [IAuditLogOptions]
  IAuditLogOptions(RawApiMap raw);
}

class AuditLogOptions implements IAuditLogOptions {
  @override
  late final Snowflake? channelId;

  @override
  late final int? count;

  @override
  late final String? deleteMemberDelay;

  @override
  late final Snowflake? id;

  @override
  late final int? pruneCount;

  @override
  late final Snowflake? messageId;

  @override
  late final String? roleName;

  @override
  late final String? overwrittenType;

  AuditLogOptions(RawApiMap raw) {
    channelId = (raw['channel_id'] as String?)?.toSnowflake();
    count = raw['count'] as int?;
    deleteMemberDelay = raw['delete_member_days'] as String?;
    id = (raw['id'] as String?)?.toSnowflake();
    pruneCount = (raw['members_removed'] as String?) != null ? int.parse(raw['members_removed'] as String) : null;
    messageId = (raw['message_id'] as String?)?.toSnowflake();
    roleName = raw['role_name'] as String?;
    if(raw['type'] != null) {
      switch(raw['type']) {
        case '0':
          overwrittenType = 'role';
          break;
        case '1':
          overwrittenType = 'member';
          break;
        default:
          overwrittenType = null;
      }
    } else {
      overwrittenType = null;
    }
  }
}