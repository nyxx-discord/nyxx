import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/snowflake.dart';

class AutoModerationRuleBuilder extends CreateBuilder<AutoModerationRule> {
  /// {@template auto_moderation_rule_name}
  /// The rule name.
  /// {@endtemplate}
  String name;

  /// {@ŧemplate auto_moderation_rule_event_type}
  /// The event type that will trigger this rule.
  /// {@endtemplate}
  AutoModerationEventType eventType;

  /// The trigger type that will trigger this rule.
  TriggerType triggerType;

  /// {@template auto_moderation_rule_trigger_metadata}
  /// The trigger metadata.
  /// {@endtemplate}
  TriggerMetadata? metadata;

  /// {@template auto_moderation_rule_actions}
  /// The actions that will be executed when this rule is triggered.
  /// {@endtemplate}
  List<AutoModerationAction> actions;

  /// {@template auto_moderation_rule_is_enabled}
  /// Whether this rule is enabled.
  /// {@endtemplate}
  bool? isEnabled;

  /// {@template auto_moderation_rule_exempt_role_ids}
  /// The role ids that are exempt from this rule.
  /// {@endtemplate}
  List<Snowflake>? exemptRoleIds;

  /// {@template auto_moderation_rule_exempt_channel_ids}
  /// The channel ids that are exempt from this rule.
  /// {@endtemplate}
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
  /// {@macro auto_moderation_rule_name}
  String? name;

  /// {@macro auto_moderation_rule_event_type}
  AutoModerationEventType? eventType;

  /// {@macro auto_moderation_rule_trigger_metadata}
  TriggerMetadata? metadata;

  /// {@macro auto_moderation_rule_actions}
  List<AutoModerationAction>? actions;

  /// {@macro auto_moderation_rule_is_enabled}
  bool? isEnabled;

  /// {@macro auto_moderation_rule_exempt_role_ids}
  List<Snowflake>? exemptRoleIds;

  /// {@macro auto_moderation_rule_exempt_channel_ids}
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
