import 'package:nyxx/src/core/audit_logs/audit_log_entry.dart';
import 'package:nyxx/src/core/guild/auto_moderation.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';
import 'package:nyxx/src/core/guild/webhook.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAuditLog {
  /// Map of webhooks found in the audit log.
  late final Map<Snowflake, IWebhook> webhooks;

  /// Map of users found in the audit log.
  late final Map<Snowflake, IUser> users;

  /// Map of audit log entries.
  late final Map<Snowflake, IAuditLogEntry> entries;

  /// Map of auto moderation rules referenced in the audit log.
  late final Map<Snowflake, IAutoModerationRule> autoModerationRules;

  /// Map of guild scheduled events referenced in the audit log.
  late final Map<Snowflake, IGuildEvent> events;

  /// Filters audit log by [users]
  Iterable<IAuditLogEntry> filter(bool Function(IAuditLogEntry) test);
}

/// Whenever an admin action is performed on the API, an entry is added to the respective guild's audit log.
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLog implements IAuditLog {
  /// Map of webhooks found in the audit log
  @override
  late final Map<Snowflake, IWebhook> webhooks;

  /// Map of users found in the audit log
  @override
  late final Map<Snowflake, IUser> users;

  /// Map of audit log entries
  @override
  late final Map<Snowflake, IAuditLogEntry> entries;

  /// Map of auto moderation rules referenced in the audit log
  @override
  late final Map<Snowflake, IAutoModerationRule> autoModerationRules;

  /// Map of guild scheduled events referenced in the audit log
  @override
  late final Map<Snowflake, IGuildEvent> events;

  /// Creates an instance of [AuditLog]
  AuditLog(RawApiMap raw, INyxx client) {
    webhooks = {};
    users = {};
    entries = {};

    raw["webhooks"].forEach((o) {
      webhooks[Snowflake(o["id"] as String)] = Webhook(o as RawApiMap, client);
    });

    raw["users"].forEach((o) {
      users[Snowflake(o["id"] as String)] = User(client, o as RawApiMap);
    });

    raw["audit_log_entries"].forEach((o) {
      entries[Snowflake(o["id"] as String)] = AuditLogEntry(o as RawApiMap, client);
    });

    raw['auto_moderation_rules'].forEach((o) {
      autoModerationRules[Snowflake(o['id'] as String)] = AutoModerationRule(o as RawApiMap, client);
    });

    raw['guild_scheduled_events'].forEach((o) {
      events[Snowflake(o['id'] as String)] = GuildEvent(o as RawApiMap, client);
    });
  }

  /// Filters audit log by [entries]
  @override
  Iterable<IAuditLogEntry> filter(bool Function(IAuditLogEntry) test) => entries.values.where(test);
}
