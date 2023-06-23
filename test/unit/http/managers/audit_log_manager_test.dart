import 'package:matcher/expect.dart';
import 'package:nyxx/nyxx.dart';

import '../../../test_manager.dart';

final sampleAuditLogEntry = {
  'target_id': '1',
  'id': '1',
  'action_type': 1,
  'reason': 'Test reason',
};

void checkAuditLogEntry(AuditLogEntry entry) {}

final sampleAuditLog = {
  'application_commands': [],
  'audit_log_entries': [sampleAuditLogEntry],
  'auto_moderation_rules': [],
  'guild_scheduled_events': [],
  'integrations': [],
  'threads': [],
  'users': [],
  'webhooks': [],
};

void main() {
  testReadOnlyManager<AuditLogEntry, AuditLogManager>(
    'AuditLogManager',
    (config, client) => AuditLogManager(config, client, guildId: Snowflake.zero),
    // fetch() artificially creates a before field as before = id + 1 - testing ID is 1 so before is 2
    '/guilds/0/audit-logs?before=2',
    sampleObject: sampleAuditLogEntry,
    sampleMatches: checkAuditLogEntry,
    // Fetch implementation internally uses `list()`, so we return a full audit log
    fetchObjectOverride: sampleAuditLog,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<AuditLogManager, List<AuditLogEntry>, Map<String, Object?>>(
        name: 'list',
        source: sampleAuditLog,
        urlMatcher: '/guilds/0/audit-logs',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));
          checkAuditLogEntry(list.single);
        },
      ),
    ],
  );
}
