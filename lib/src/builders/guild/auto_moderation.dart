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

  TriggerMetadataBuilder? metadata;

  List<AutoModerationActionBuilder>? actions;

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
        if (metadata != null) 'trigger_metadata': metadata!.build(),
        if (actions != null) 'actions': actions!.map((a) => a.build()).toList(),
        if (isEnabled != null) 'enabled': isEnabled,
        if (exemptRoleIds != null) 'exempt_roles': exemptRoleIds!.map((id) => id.toString()).toList(),
        if (exemptChannelIds != null) 'exempt_channels': exemptChannelIds!.map((id) => id.toString()).toList(),
      };
}

class TriggerMetadataBuilder extends CreateBuilder<TriggerMetadata> {
  /// A list of words that trigger the rule.
  final List<String>? keywordFilter;

  /// A list of regex patterns that trigger the rule.
  final List<String>? regexPatterns;

  /// A list of preset keyword types that trigger the rule.
  final List<KeywordPresetType>? presets;

  /// A list of words allowed to bypass the rule.
  final List<String>? allowList;

  /// The maximum number of mentions in a message.
  final int? mentionTotalLimit;

  /// Whether mention raid protection is enabled.
  final bool? isMentionRaidProtectionEnabled;

  TriggerMetadataBuilder({
    required this.keywordFilter,
    required this.regexPatterns,
    required this.presets,
    required this.allowList,
    required this.mentionTotalLimit,
    required this.isMentionRaidProtectionEnabled,
  });

  @override
  Map<String, Object?> build() => {
        'keyword_filter': keywordFilter,
        'regex_patterns': regexPatterns,
        'presets': presets?.map((type) => type.value).toList(),
        'allow_list': allowList,
        'mention_total_limit': mentionTotalLimit,
        'mention_raid_protection_enabled': isMentionRaidProtectionEnabled,
      };
}

class AutoModerationActionBuilder extends CreateBuilder<AutoModerationAction> {
  /// The type of action to perform.
  final ActionType type;

  /// Metadata needed to perform the action.
  final ActionMetadataBuilder? metadata;

  AutoModerationActionBuilder({required this.type, required this.metadata});

  @override
  Map<String, Object?> build() => {
        'type': type.value,
        if (metadata != null) 'metadata': metadata!.build(),
      };
}

class ActionMetadataBuilder extends CreateBuilder<ActionMetadata> {
  /// The ID of the channel to send the alert message to.
  final Snowflake? channelId;

  /// The duration of time to time the user out for.
  final Duration? duration;

  /// A custom message to send to the user.
  final String? customMessage;

  ActionMetadataBuilder({
    required this.channelId,
    required this.duration,
    required this.customMessage,
  });

  @override
  Map<String, Object?> build() => {
        'channel_id': channelId?.toString(),
        'duration_seconds': duration?.inSeconds,
        'custom_message': customMessage,
      };
}
