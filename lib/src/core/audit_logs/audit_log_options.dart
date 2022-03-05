import 'package:nyxx/nyxx.dart';

/// Additionnal info for certain action types
///
/// [Look here for more](https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events)
abstract class IAuditLogOptions {
  /// The channel in which the entites were targeted.
  Snowflake? get channelId;

  /// The number of entities targeted.
  int? get count;

  /// The number of days after which inactive users will be kicked.
  Duration? get deleteMemberDuration;

  /// Id of the overwritten entity.
  Snowflake? get id;

  /// The number of the members removed by the prune.
  int? get pruneCount;

  /// The id of the message that was targeted.
  Snowflake? get messageId;

  /// The name of the role that was targeted. (Not present if [overwrittenType] is `member`).
  String? get roleName;

  /// Type of overwritten entity.
  /// One of:
  ///   - `role`
  ///   - `member`
  String? get overwrittenType;

  /// The constructor for the [IAuditLogOptions]
  IAuditLogOptions(RawApiMap raw);
}

class AuditLogOptions implements IAuditLogOptions {
  /// The channel in which the entites were targeted.
  @override
  late final Snowflake? channelId;

  /// The number of entities targeted.
  @override
  late final int? count;

  /// The number of days after which inactive users will be kicked.
  @override
  late final Duration? deleteMemberDuration;

  /// Id of the overwritten entity.
  @override
  late final Snowflake? id;

  /// The number of the members removed by the prune.
  @override
  late final int? pruneCount;

  /// The id of the message that was targeted.
  @override
  late final Snowflake? messageId;

  /// The name of the role that was targeted. (Not present if [overwrittenType] is `member`).
  @override
  late final String? roleName;

  /// Type of overwritten entity.
  /// One of:
  ///  - `role`
  /// - `member`
  @override
  late final String? overwrittenType;

  AuditLogOptions(RawApiMap raw) {
    channelId = (raw['channel_id'] as String?)?.toSnowflake();
    count = raw['count'] != null ? int.parse(raw['count'] as String) : null;
    deleteMemberDuration = (raw['delete_member_days'] as String?) != null ? Duration(days: int.parse(raw['delete_member_days'] as String)) : null;
    id = (raw['id'] as String?)?.toSnowflake();
    pruneCount = (raw['members_removed'] as String?) != null ? int.parse(raw['members_removed'] as String) : null;
    messageId = (raw['message_id'] as String?)?.toSnowflake();
    roleName = raw['role_name'] as String?;
    switch (raw['type']) {
      case '0':
        overwrittenType = 'role';
        break;
      case '1':
        overwrittenType = 'member';
        break;
      default:
        overwrittenType = null;
    }
  }
}
