import 'dart:convert';

import 'package:nyxx/src/builders/guild/auto_moderation.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class AutoModerationManager extends Manager<AutoModerationRule> {
  final Snowflake guildId;

  AutoModerationManager(super.config, super.client, {required this.guildId}) : super(identifier: '$guildId.autoModerationRules');

  @override
  PartialAutoModerationRule operator [](Snowflake id) => PartialAutoModerationRule(id: id, manager: this);

  @override
  AutoModerationRule parse(Map<String, Object?> raw) {
    return AutoModerationRule(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      name: raw['name'] as String,
      creatorId: Snowflake.parse(raw['creator_id']!),
      eventType: AutoModerationEventType.parse(raw['event_type'] as int),
      triggerType: TriggerType.parse(raw['trigger_type'] as int),
      metadata: parseTriggerMetadata(raw['trigger_metadata'] as Map<String, Object?>),
      actions: parseMany(raw['actions'] as List<Object?>, parseAutoModerationAction),
      isEnabled: raw['enabled'] as bool,
      exemptRoleIds: parseMany(raw['exempt_roles'] as List<Object?>, Snowflake.parse),
      exemptChannelIds: parseMany(raw['exempt_channels'] as List<Object?>, Snowflake.parse),
    );
  }

  TriggerMetadata parseTriggerMetadata(Map<String, Object?> raw) {
    return TriggerMetadata(
      keywordFilter: maybeParseMany(raw['keyword_filter']),
      regexPatterns: maybeParseMany(raw['regex_patterns']),
      presets: maybeParseMany(raw['presets'], KeywordPresetType.parse),
      allowList: maybeParseMany(raw['allow_list']),
      mentionTotalLimit: raw['mention_total_limit'] as int?,
      isMentionRaidProtectionEnabled: raw['mention_raid_protection_enabled'] as bool?,
    );
  }

  AutoModerationAction parseAutoModerationAction(Map<String, Object?> raw) {
    return AutoModerationAction(
      type: ActionType.parse(raw['type'] as int),
      metadata: maybeParse(raw['metadata'], parseActionMetadata),
    );
  }

  ActionMetadata parseActionMetadata(Map<String, Object?> raw) {
    return ActionMetadata(
      manager: this,
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      duration: maybeParse(raw['duration_seconds'], (int seconds) => Duration(seconds: seconds)),
      customMessage: raw['custom_message'] as String?,
    );
  }

  @override
  Future<AutoModerationRule> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..autoModeration()
      ..rules(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final rule = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(rule);
    return rule;
  }

  Future<List<AutoModerationRule>> list() async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..autoModeration()
      ..rules();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final rules = parseMany(response.jsonBody as List<Object?>, parse);

    rules.forEach(client.updateCacheWith);
    return rules;
  }

  @override
  Future<AutoModerationRule> create(AutoModerationRuleBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..autoModeration()
      ..rules();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()), auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final rule = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(rule);
    return rule;
  }

  @override
  Future<AutoModerationRule> update(Snowflake id, AutoModerationRuleUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..autoModeration()
      ..rules(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()), auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final rule = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(rule);
    return rule;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..autoModeration()
      ..rules(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);

    cache.remove(id);
  }
}
