import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/snowflake.dart';

class AutoModerationRuleBuilder extends CreateBuilder<AutoModerationRule> {
  String name;

  AutoModerationEventType eventType;

  TriggerType triggerType;

  TriggerMetadataBuilder? metadata;

  List<AutoModerationActionBuilder> actions;

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

  AutoModerationRuleBuilder.keyword({
    required this.name,
    required this.eventType,
    required this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
    List<String>? keywordFilter,
    List<String>? regexPatterns,
    List<String>? allowList,
  })  : triggerType = TriggerType.keyword,
        metadata = TriggerMetadataBuilder(
          keywordFilter: keywordFilter,
          regexPatterns: regexPatterns,
          allowList: allowList,
        );

  AutoModerationRuleBuilder.spam({
    required this.name,
    required this.eventType,
    required this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
  })  : triggerType = TriggerType.spam,
        metadata = null;

  AutoModerationRuleBuilder.keywordPreset({
    required this.name,
    required this.eventType,
    required this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
    required List<KeywordPresetType>? presets,
    List<String>? allowList,
  })  : triggerType = TriggerType.keywordPreset,
        metadata = TriggerMetadataBuilder(
          presets: presets,
          allowList: allowList,
        );

  AutoModerationRuleBuilder.mentionSpam({
    required this.name,
    required this.eventType,
    required this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
    required int mentionTotalLimit,
    bool? isMentionRaidProtectionEnabled,
  })  : triggerType = TriggerType.mentionSpam,
        metadata = TriggerMetadataBuilder(
          mentionTotalLimit: mentionTotalLimit,
          isMentionRaidProtectionEnabled: isMentionRaidProtectionEnabled,
        );

  AutoModerationRuleBuilder.memberProfile({
    required this.name,
    required this.eventType,
    required this.actions,
    this.isEnabled,
    this.exemptRoleIds,
    this.exemptChannelIds,
    List<String>? keywordFilter,
    List<String>? regexPatterns,
    List<String>? allowList,
  })  : triggerType = TriggerType.memberProfile,
        metadata = TriggerMetadataBuilder(
          keywordFilter: keywordFilter,
          regexPatterns: regexPatterns,
          allowList: allowList,
        );

  @override
  Map<String, Object?> build() => {
        'name': name,
        'event_type': eventType.value,
        'trigger_type': triggerType.value,
        if (metadata != null) 'trigger_metadata': metadata!.build(),
        'actions': actions.map((a) => a.build()).toList(),
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
    this.keywordFilter,
    this.regexPatterns,
    this.presets,
    this.allowList,
    this.mentionTotalLimit,
    this.isMentionRaidProtectionEnabled,
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

  AutoModerationActionBuilder({required this.type, this.metadata});

  AutoModerationActionBuilder.blockMessage({String? customMessage})
      : type = ActionType.blockMessage,
        metadata = customMessage == null ? null : ActionMetadataBuilder(customMessage: customMessage);

  AutoModerationActionBuilder.sendAlertMessage({required Snowflake channelId})
      : type = ActionType.sendAlertMessage,
        metadata = ActionMetadataBuilder(channelId: channelId);

  AutoModerationActionBuilder.timeout({required Duration duration})
      : type = ActionType.timeout,
        metadata = ActionMetadataBuilder(duration: duration);

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
    this.channelId,
    this.duration,
    this.customMessage,
  });

  @override
  Map<String, Object?> build() => {
        if (channelId != null) 'channel_id': channelId!.toString(),
        if (duration != null) 'duration_seconds': duration!.inSeconds,
        if (customMessage != null) 'custom_message': customMessage,
      };
}
