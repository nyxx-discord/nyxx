import 'package:nyxx/src/core/guild/auto_moderation.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';

class AutoModerationRuleBuilder implements Builder {
  /// The name of the rule.
  String name;

  /// The event type of the rule.
  EventTypes eventType;

  /// The trigger type.
  TriggerTypes triggerType;

  /// The actions which will execute when the rule is triggered
  List<ActionStructureBuilder> actions;

  /// The trigger metadata.
  ///
  /// Can be omitted as it is based on [triggerType].
  TriggerMetadataBuilder? triggerMetadata;

  /// Whether this rule is enabled. `false` by default.
  bool? enabled;

  /// The role IDs that should not be affected by the rule. (Maximum of 20).
  List<Snowflake>? ignoredRoles;

  /// The channel ids that should not be affected by the rule. (Maximum of 50).
  List<Snowflake>? ignoredChannels;

  AutoModerationRuleBuilder(this.name, {required this.eventType, required this.triggerType, required this.actions});

  @override
  RawApiMap build() => {
        'name': name,
        'event_type': eventType.value,
        'trigger_type': triggerType.value,
        'actions': actions.map((a) => a.build()).toList(),
        if (triggerMetadata != null) 'trigger_metadata': triggerMetadata!.build(),
        if (enabled != null) 'enabled': enabled,
        if (ignoredRoles != null) 'exempt_roles': ignoredRoles!.map((s) => s.toString()).toList(),
        if (ignoredChannels != null) 'exempt_channels': ignoredChannels!.map((s) => s.toString()).toList(),
      };
}

class ActionStructureBuilder implements Builder {
  /// The type for this action.
  ActionTypes actionType;

  /// Additional metadata needed during execution for this specific action type
  ActionMetadataBuilder metadata;

  ActionStructureBuilder(this.actionType, this.metadata);

  @override
  RawApiMap build() => {
        'type': actionType.value,
        'metadata': metadata.build(),
      };
}

class ActionMetadataBuilder implements Builder {
  /// Channel to which messages content should be logged.
  ///
  /// (Works only when it's action type is [ActionTypes.sendAlertMessage]).
  Snowflake? channelId;

  /// The duration of the timeout.
  /// This cannot exceed 4 weeks!
  ///
  /// (Works only when it's action type is [ActionTypes.timeout]).
  Duration? duration;

  ActionMetadataBuilder({this.channelId, this.duration});

  @override
  RawApiMap build() => {
        if (channelId != null) 'channel_id': channelId.toString(),
        if (duration != null) 'duration_seconds': duration!.inSeconds,
      };
}

class TriggerMetadataBuilder implements Builder {
  /// Substrings which will be searched for in content.
  List<String>? keywordFilter;

  /// The internally pre-defined wordsets which will be searched for in content.
  List<KeywordPresets>? presets;

  /// Substrings which will be exempt from triggering the preset trigger type.
  List<String>? allowList;

  /// The total number of mentions (either role and user) allowed per message.
  /// (Maximum of 50)
  // Pr still not merged
  int? mentionLimit;

  @override
  RawApiMap build() => {
        if (keywordFilter != null) 'keyword_filter': keywordFilter,
        if (presets != null) 'presets': presets!.map((e) => e.value).toList(),
        if (allowList != null) 'allow_list': allowList,
        if (mentionLimit != null) 'mention_total_limit': mentionLimit,
      };
}
