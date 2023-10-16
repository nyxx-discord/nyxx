import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleAutoModerationRule = {
  "id": "969707018069872670",
  "guild_id": "613425648685547541",
  "name": "Keyword Filter 1",
  "creator_id": "423457898095789043",
  "trigger_type": 1,
  "event_type": 1,
  "actions": [
    {
      "type": 1,
      "metadata": {"custom_message": "Please keep financial discussions limited to the #finance channel"}
    },
    {
      "type": 2,
      "metadata": {"channel_id": "123456789123456789"}
    },
    {
      "type": 3,
      "metadata": {"duration_seconds": 60}
    }
  ],
  "trigger_metadata": {
    "keyword_filter": ["cat*", "*dog", "*ana*", "i like c++"],
    "regex_patterns": ["(b|c)at", "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\$"]
  },
  "enabled": true,
  "exempt_roles": ["323456789123456789", "423456789123456789"],
  "exempt_channels": ["523456789123456789"]
};

void checkAutoModerationRule(AutoModerationRule rule) {}

void main() {
  testManager<AutoModerationRule, AutoModerationManager>(
    'AutoModerationManager',
    (config, client) => AutoModerationManager(config, client, guildId: Snowflake.zero),
    RegExp(r'/guilds/0/auto-moderation/rules/\d+'),
    '/guilds/0/auto-moderation/rules',
    sampleObject: sampleAutoModerationRule,
    sampleMatches: checkAutoModerationRule,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<AutoModerationManager, List<AutoModerationRule>, List<Object?>>(
        name: 'list',
        source: [sampleAutoModerationRule],
        urlMatcher: '/guilds/0/auto-moderation/rules',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));
          checkAutoModerationRule(list.single);
        },
      ),
    ],
    createBuilder: AutoModerationRuleBuilder(name: 'test', eventType: AutoModerationEventType.messageSend, triggerType: TriggerType.keyword, actions: []),
    updateBuilder: AutoModerationRuleUpdateBuilder(),
  );
}
