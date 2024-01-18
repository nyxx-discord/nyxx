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
  messageSend._(1);

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
  keyword._(1),
  spam._(3),
  keywordPreset._(4),
  mentionSpam._(5);

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
class TriggerMetadata with ToStringHelper {
  /// A list of words that trigger the rule.
  final List<String>? keywordFilter;

  /// A list of regex patterns that trigger the rule.
  // TODO: Do we want to parse these as RegExp objects?
  final List<String>? regexPatterns;

  /// A list of preset keyword types that trigger the rule.
  final List<KeywordPresetType>? presets;

  /// A list of words allowed to bypass the rule.
  final List<String>? allowList;

  /// The maximum number of mentions in a message.
  final int? mentionTotalLimit;

  /// Whether mention raid protection is enabled.
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
class AutoModerationAction with ToStringHelper {
  /// The type of action to perform.
  final ActionType type;

  /// Metadata needed to perform the action.
  final ActionMetadata? metadata;

  /// {@macro auto_moderation_action}
  /// @nodoc
  AutoModerationAction({
    required this.type,
    required this.metadata,
  });
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
class ActionMetadata with ToStringHelper {
  final AutoModerationManager manager;

  /// The ID of the channel to send the alert message to.
  final Snowflake? channelId;

  /// The duration of time to time the user out for.
  final Duration? duration;

  /// A custom message to send to the user.
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
}
