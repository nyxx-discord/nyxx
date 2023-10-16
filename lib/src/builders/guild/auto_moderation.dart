import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/snowflake.dart';

class AutoModerationRuleBuilder extends CreateBuilder<AutoModerationRule> {
  String name;

  AutoModerationEventType eventType;

  TriggerType triggerType;

  TriggerMetadata? metadata;

  List<AutoModerationAction> actions;

  bool? isEnabled;

  List<Snowflake>? exemptRoleIds;

  List<Snowflake>? exemptChannelIds;

  AutoModerationRuleBuilder({
    required this.name,
    required this.eventType,
    required this.triggerType,
    this.metadata,
    required this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        'event_type': eventType.value,
        'trigger_type': triggerType.value,
        if (metadata != null)
          'trigger_metadata': {
            'keyword_filter': metadata!.keywordFilter,
            'regex_patterns': metadata!.regexPatterns,
            'presets': metadata!.presets?.map((type) => type.value).toList(),
            'allow_list': metadata!.allowList,
            'mention_total_limit': metadata!.mentionTotalLimit,
            'mention_raid_protection_enabled': metadata!.isMentionRaidProtectionEnabled,
          },
        'actions': [
          for (final action in actions)
            {
              'type': action.type.value,
              if (action.metadata != null)
                'metadata': {
                  'channel_id': action.metadata!.channelId?.toString(),
                  'duration_seconds': action.metadata!.duration?.inSeconds,
                  'custom_message': action.metadata!.customMessage,
                }
            }
        ],
        if (isEnabled != null) 'enabled': isEnabled,
        if (exemptRoleIds != null) 'exempt_roles': exemptRoleIds!.map((id) => id.toString()).toList(),
        if (exemptChannelIds != null) 'exempt_channels': exemptChannelIds!.map((id) => id.toString()).toList(),
      };
}

class AutoModerationRuleUpdateBuilder extends UpdateBuilder<AutoModerationRule> {
  String? name;

  AutoModerationEventType? eventType;

  TriggerMetadata? metadata;

  List<AutoModerationAction>? actions;

  bool? isEnabled;

  List<Snowflake>? exemptRoleIds;

  List<Snowflake>? exemptChannelIds;

  AutoModerationRuleUpdateBuilder({
    this.name,
    this.eventType,
    this.metadata,
    this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (eventType != null) 'event_type': eventType!.value,
        if (metadata != null)
          'trigger_metadata': {
            'keyword_filter': metadata!.keywordFilter,
            'regex_patterns': metadata!.regexPatterns,
            'presets': metadata!.presets?.map((type) => type.value).toList(),
            'allow_list': metadata!.allowList,
            'mention_total_limit': metadata!.mentionTotalLimit,
            'mention_raid_protection_enabled': metadata!.isMentionRaidProtectionEnabled,
          },
        if (actions != null)
          'actions': [
            for (final action in actions!)
              {
                'type': action.type.value,
                if (action.metadata != null)
                  'metadata': {
                    'channel_id': action.metadata!.channelId?.toString(),
                    'duration_seconds': action.metadata!.duration?.inSeconds,
                    'custom_message': action.metadata!.customMessage,
                  }
              }
          ],
        if (isEnabled != null) 'enabled': isEnabled,
        if (exemptRoleIds != null) 'exempt_roles': exemptRoleIds!.map((id) => id.toString()).toList(),
        if (exemptChannelIds != null) 'exempt_channels': exemptChannelIds!.map((id) => id.toString()).toList(),
      };
}
