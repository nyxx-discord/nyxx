import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/audit_logs/AuditLogEntry.dart';
import 'package:nyxx/src/core/guild/Webhook.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAuditLog {
  /// List of webhooks found in the audit log
  late final Map<Snowflake, IWebhook> webhooks;

  /// List of users found in the audit log
  late final Map<Snowflake, IUser> users;

  /// List of audit log entries
  late final Map<Snowflake, IAuditLogEntry> entries;

  /// Filters audit log by [users]
  Iterable<IAuditLogEntry> filter(bool Function(IAuditLogEntry) test);
}

/// Whenever an admin action is performed on the API, an entry is added to the respective guild's audit log.
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLog implements IAuditLog {
  /// List of webhooks found in the audit log
  @override
  late final Map<Snowflake, IWebhook> webhooks;

  /// List of users found in the audit log
  @override
  late final Map<Snowflake, IUser> users;

  /// List of audit log entries
  @override
  late final Map<Snowflake, IAuditLogEntry> entries;

  /// Creates na instance of [AuditLog]
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
  }

  /// Filters audit log by [users]
  @override
  Iterable<IAuditLogEntry> filter(bool Function(IAuditLogEntry) test) =>
      entries.values.where(test);
}
