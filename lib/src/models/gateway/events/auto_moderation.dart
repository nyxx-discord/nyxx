import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template auto_moderation_rule_create_event}
/// Emitted when an auto moderation rule is created.
/// {@endtemplate}
class AutoModerationRuleCreateEvent extends DispatchEvent {
  /// The rule that was created.
  final AutoModerationRule rule;

  /// {@macro auto_moderation_rule_create_event}
  AutoModerationRuleCreateEvent({required this.rule});
}

/// {@template auto_moderation_rule_update_event}
/// Emitted when an auto moderation rule is updated.
/// {@endtemplate}
class AutoModerationRuleUpdateEvent extends DispatchEvent {
  /// The rule as it was cached before it was updated.
  final AutoModerationRule? oldRule;

  /// The rule that was updated.
  final AutoModerationRule rule;

  /// {@macro auto_moderation_rule_update_event}
  AutoModerationRuleUpdateEvent({required this.oldRule, required this.rule});
}

/// {@template auto_moderation_rule_delete_event}
/// Emitted when an auto moderation rule is deleted.
/// {@endtemplate}
class AutoModerationRuleDeleteEvent extends DispatchEvent {
  /// The rule that was deleted.
  final AutoModerationRule rule;

  /// {@macro auto_moderation_rule_delete_event}
  AutoModerationRuleDeleteEvent({required this.rule});
}

/// {@template auto_moderation_action_execution_event}
/// Emitted when an auto moderation action is taken.
/// {@endtemplate}
class AutoModerationActionExecutionEvent extends DispatchEvent {
  /// The ID of the guild the event was triggered in.
  final Snowflake guildId;

  /// The action that was taken.
  final AutoModerationAction action;

  /// The ID of the rule that was triggered.
  final Snowflake ruleId;

  /// The trigger type that triggered the action.
  final TriggerType triggerType;

  /// The ID of the user that triggered the action.
  final Snowflake userId;

  /// The ID of the channel in which the action was taken.
  final Snowflake? channelId;

  /// The ID of the message the action was taken on.
  final Snowflake? messageId;

  /// The ID of the message sent in the alert channel.
  final Snowflake? alertSystemMessageId;

  /// The content of the message which triggered the action.
  final String? content;

  /// The keyword which was matched.
  final String? matchedKeyword;

  /// The content of the message which was matched.
  final String? matchedContent;

  /// {@macro auto_moderation_action_execution_event}
  AutoModerationActionExecutionEvent({
    required this.guildId,
    required this.action,
    required this.ruleId,
    required this.triggerType,
    required this.userId,
    required this.channelId,
    required this.messageId,
    required this.alertSystemMessageId,
    required this.content,
    required this.matchedKeyword,
    required this.matchedContent,
  });
}
