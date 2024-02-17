import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/audit_log.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class AuditLogManager extends ReadOnlyManager<AuditLogEntry> {
  final Snowflake guildId;

  AuditLogManager(super.config, super.client, {required this.guildId}) : super(identifier: '$guildId.auditLogEntries');

  @override
  PartialAuditLogEntry operator [](Snowflake id) => PartialAuditLogEntry(id: id, manager: this);

  @override
  AuditLogEntry parse(Map<String, Object?> raw) {
    return AuditLogEntry(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      targetId: maybeParse(raw['target_id'], Snowflake.parse),
      changes: maybeParseMany(raw['changes'], parseAuditLogChange),
      userId: maybeParse(raw['user_id'], Snowflake.parse),
      actionType: AuditLogEvent.parse(raw['action_type'] as int),
      options: maybeParse(raw['options'], parseAuditLogEntryInfo),
      reason: raw['reason'] as String?,
    );
  }

  /// Parse a [AuditLogChange] from [raw].
  AuditLogChange parseAuditLogChange(Map<String, Object?> raw) {
    return AuditLogChange(
      oldValue: raw['old_value'],
      newValue: raw['new_value'],
      key: raw['key'] as String,
    );
  }

  /// Parse a [AuditLogEntryInfo] from [raw].
  AuditLogEntryInfo parseAuditLogEntryInfo(Map<String, Object?> raw) {
    return AuditLogEntryInfo(
      manager: this,
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      autoModerationRuleName: raw['auto_moderation_rule_name'] as String?,
      autoModerationTriggerType: raw['auto_moderation_rule_trigger_type'] as String?,
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      count: raw['count'] as String?,
      deleteMemberDays: raw['delete_member_days'] as String?,
      id: maybeParse(raw['id'], Snowflake.parse),
      membersRemoved: raw['members_removed'] as String?,
      messageId: maybeParse(raw['message_id'], Snowflake.parse),
      roleName: raw['role_name'] as String?,
      overwriteType: maybeParse(raw['type'], (String raw) => PermissionOverwriteType.parse(int.parse(raw))),
      integrationType: raw['integration_type'] as String?,
    );
  }

  @override
  Future<AuditLogEntry> fetch(Snowflake id) async {
    // Add one because before and after are exclusive.
    final entries = await list(before: Snowflake(id.value + 1));

    return entries.firstWhere(
      (entry) => entry.id == id,
      orElse: () => throw AuditLogEntryNotFoundException(guildId, id),
    );
  }

  // List the audit log in the guild.
  Future<List<AuditLogEntry>> list({Snowflake? userId, AuditLogEvent? type, Snowflake? before, Snowflake? after, int? limit}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..auditLogs();
    final request = BasicRequest(route, queryParameters: {
      if (userId != null) 'user_id': userId.toString(),
      if (type != null) 'action_type': type.value.toString(),
      if (before != null) 'before': before.toString(),
      if (after != null) 'after': after.toString(),
      if (limit != null) 'limit': limit.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final responseBody = response.jsonBody as Map<String, Object?>;
    final entries = parseMany(responseBody['audit_log_entries'] as List<Object?>, parse);

    final applicationCommands = parseMany(responseBody['application_commands'] as List<Object?>, (Map<String, Object?> raw) {
      final guildId = maybeParse(raw['guild_id'], Snowflake.parse);

      if (guildId == null) {
        return client.commands.parse(raw);
      }

      return client.guilds[guildId].commands.parse(raw);
    });
    applicationCommands.forEach(client.updateCacheWith);

    final autoModerationRules = parseMany(responseBody['auto_moderation_rules'] as List<Object?>, client.guilds[guildId].autoModerationRules.parse);
    autoModerationRules.forEach(client.updateCacheWith);

    final scheduledEvents = parseMany(responseBody['guild_scheduled_events'] as List<Object?>, client.guilds[guildId].scheduledEvents.parse);
    scheduledEvents.forEach(client.updateCacheWith);

    final threads = parseMany(responseBody['threads'] as List<Object?>, client.channels.parse);
    threads.forEach(client.updateCacheWith);

    final users = parseMany(responseBody['users'] as List<Object?>, client.users.parse);
    users.forEach(client.updateCacheWith);

    final webhooks = parseMany(responseBody['webhooks'] as List<Object?>, client.webhooks.parse);
    webhooks.forEach(client.updateCacheWith);

    entries.forEach(client.updateCacheWith);
    return entries;
  }
}
