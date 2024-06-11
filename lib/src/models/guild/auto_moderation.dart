import 'package:nyxx/src/builders/guild/auto_moderation.dart';
import 'package:nyxx/src/http/managers/auto_moderation_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [AutoModerationRule].
class PartialAutoModerationRule extends WritableSnowflakeEntity<AutoModerationRule> {
  @override
  final AutoModerationManager manager;

  /// Create a new [PartialAutoModerationRule].
  /// @nodoc
  PartialAutoModerationRule({required super.id, required this.manager});
}

/// {@template auto_moderation_rule}
/// A rule use for auto-moderation in a [Guild].
/// {@endtemplate}
class AutoModerationRule extends PartialAutoModerationRule {
  /// The ID of the guild this rule is in.
  final Snowflake guildId;

  /// The name of this rule.
  final String name;

  /// The ID of the user that created this rule.
  final Snowflake creatorId;

  /// The type of event on which this rule triggers.
  final AutoModerationEventType eventType;

  /// The type of trigger for this rule.
  final TriggerType triggerType;

  /// Any metadata associated with this rule.
  final TriggerMetadata metadata;

  /// The actions taken when this rule is triggered.
  final List<AutoModerationAction> actions;

  /// Whether this rule is enabled.
  final bool isEnabled;

  /// The IDs of the roles exempt to this rule.
  final List<Snowflake> exemptRoleIds;

  /// The IDs of the channels exempt to this rule.
  final List<Snowflake> exemptChannelIds;

  /// {@macro auto_moderation_rule}
  /// @nodoc
  AutoModerationRule({
    required super.id,
    required super.manager,
    required this.guildId,
    required this.name,
    required this.creatorId,
    required this.eventType,
    required this.triggerType,
    required this.metadata,
    required this.actions,
    required this.isEnabled,
    required this.exemptRoleIds,
    required this.exemptChannelIds,
  });

  PartialGuild get guild => manager.client.guilds[guildId];

  PartialUser get creator => manager.client.users[creatorId];

  PartialMember get creatorMember => guild.members[creatorId];

  List<PartialRole> get exemptRoles => exemptRoleIds.map((e) => guild.roles[e]).toList();

  List<PartialChannel> get exemptChannels => exemptChannelIds.map((e) => manager.client.channels[e]).toList();
}

/// The type of event on which an [AutoModerationRule] triggers.
enum AutoModerationEventType {
  /// When a member sends or edits a message in the guild.
  messageSend._(1),

  /// When a member edits their profile.
  memberUpdate(2);

  /// The value of this [AutoModerationEventType].
  final int value;

  const AutoModerationEventType._(this.value);

  /// Parse an [AutoModerationEventType] from an [int].
  ///
  /// The [value] must be a valid auto moderation event type.
  factory AutoModerationEventType.parse(int value) => AutoModerationEventType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown auto moderation event type', value),
      );

  @override
  String toString() => 'AutoModerationEventType($value)';
}

/// The type of a trigger for an [AutoModerationRule]
enum TriggerType {
  /// Check if content contains words from a user defined list of keywords.
  keyword._(1),

  /// Check if content represents generic spam.
  spam._(3),

  /// Check if content contains words from internal pre-defined wordsets.
  keywordPreset._(4),

  /// Check if content contains more unique mentions than allowed.
  mentionSpam._(5),

  /// Check if member profile contains words from a user defined list of keywords.
  memberProfile(6);

  /// The value of this [TriggerType].
  final int value;

  const TriggerType._(this.value);

  /// Parse an [TriggerType] from an [int].
  ///
  /// The [value] must be a valid trigger type.
  factory TriggerType.parse(int value) => TriggerType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown trigger type', value),
      );

  @override
  String toString() => 'TriggerType($value)';
}

/// {@template trigger_metadata}
/// Additional metadata associated with the trigger for an [AutoModerationRule].
/// {@endtemplate}
// TODO(abitofevrything): Remove `implements TriggerMetadataBuilder`
class TriggerMetadata with ToStringHelper implements TriggerMetadataBuilder {
  @override
  final List<String>? keywordFilter;

  // TODO: Do we want to parse these as RegExp objects?
  @override
  final List<String>? regexPatterns;

  @override
  final List<KeywordPresetType>? presets;

  @override
  final List<String>? allowList;

  @override
  final int? mentionTotalLimit;

  @override
  final bool? isMentionRaidProtectionEnabled;

  /// {@macro trigger_metadata}
  /// @nodoc
  TriggerMetadata({
    required this.keywordFilter,
    required this.regexPatterns,
    required this.presets,
    required this.allowList,
    required this.mentionTotalLimit,
    required this.isMentionRaidProtectionEnabled,
  });

  @override
  @Deprecated('Use TriggerMetadataBuilder instead')
  Map<String, Object?> build() => {
        'keyword_filter': keywordFilter,
        'regex_patterns': regexPatterns,
        'presets': presets?.map((type) => type.value).toList(),
        'allow_list': allowList,
        'mention_total_limit': mentionTotalLimit,
        'mention_raid_protection_enabled': isMentionRaidProtectionEnabled,
      };
}

/// A preset list of trigger keywords for an [AutoModerationRule].
enum KeywordPresetType {
  profanity._(1),
  sexualContent._(2),
  slurs._(3);

  /// The value of this [KeywordPresetType].
  final int value;

  const KeywordPresetType._(this.value);

  /// Parse an [KeywordPresetType] from an [int].
  ///
  /// The [value] must be a valid keyword preset type.
  factory KeywordPresetType.parse(int value) => KeywordPresetType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown keyword preset type', value),
      );

  @override
  String toString() => 'KeywordPresetType($value)';
}

/// {@template auto_moderation_action}
/// Describes an action to take when an [AutoModerationRule] is triggered.
/// {@endtemplate}
// TODO(abitofevrything): Remove `implements AutoModerationActionBuilder`
class AutoModerationAction with ToStringHelper implements AutoModerationActionBuilder {
  @override
  final ActionType type;

  @override
  final ActionMetadata? metadata;

  /// {@macro auto_moderation_action}
  /// @nodoc
  AutoModerationAction({
    required this.type,
    required this.metadata,
  });

  @override
  @Deprecated('Use AutoModerationActionBuilder instead')
  Map<String, Object?> build() => {
        'type': type.value,
        if (metadata != null) 'metadata': metadata!.build(),
      };
}

/// The type of action for an [AutoModerationAction].
enum ActionType {
  blockMessage._(1),
  sendAlertMessage._(2),
  timeout._(3);

  /// The value of this [ActionType].
  final int value;

  const ActionType._(this.value);

  /// Parse an [ActionType] from an [int].
  ///
  /// The [value] must be a valid action type.
  factory ActionType.parse(int value) => ActionType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown action type', value),
      );

  @override
  String toString() => 'ActionType($value)';
}

/// {@template action_metadata}
/// Additional metadata associated with an [AutoModerationAction].
/// {@endtemplate}
// TODO(abitofevrything): Remove `implements ActionMetadataBuilder`
class ActionMetadata with ToStringHelper implements ActionMetadataBuilder {
  final AutoModerationManager manager;

  @override
  final Snowflake? channelId;

  @override
  final Duration? duration;

  @override
  final String? customMessage;

  /// {@macro action_metadata}
  /// @nodoc
  ActionMetadata({
    required this.manager,
    required this.channelId,
    required this.duration,
    required this.customMessage,
  });

  /// The channel to send the alert message to.
  PartialTextChannel? get channel => channelId == null ? null : manager.client.channels[channelId!] as PartialTextChannel?;

  @override
  @Deprecated('Use ActionMetadataBuilder instead')
  Map<String, Object?> build() => {
        'channel_id': channelId?.toString(),
        'duration_seconds': duration?.inSeconds,
        'custom_message': customMessage,
      };
}
