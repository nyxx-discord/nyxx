import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template auto_moderation_rule_create_event}
/// Emitted when an auto moderation rule is created.
/// {@endtemplate}
class AutoModerationRuleCreateEvent extends DispatchEvent {
  // TODO
  //final AutoModerationRule rule;
}

/// {@template auto_moderation_rule_update_event}
/// Emitted when an auto moderation rule is updated.
/// {@endtemplate}
class AutoModerationRuleUpdateEvent extends DispatchEvent {
  // TODO
  //final AutoModerationRule rule;
}

/// {@template auto_moderation_rule_delete_event}
/// Emitted when an auto moderation rule is deleted.
/// {@endtemplate}
class AutoModerationRuleDeleteEvent extends DispatchEvent {
  // TODO
  //final AutoModerationRule rule;
}

/// {@template auto_moderation_action_execution_event}
/// Emitted when an auto moderation action is taken.
/// {@endtemplate}
class AutoModerationActionExecutionEvent extends DispatchEvent {
  /// The ID of the guild the event was triggered in.
  final Snowflake guildId;

  // TODO
  //final AutoModerationAction action;

  /// The ID of the rule that was triggered.
  final Snowflake ruleId;

  // TODO
  //final TriggerType triggerType;

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
    required this.ruleId,
    required this.userId,
    required this.channelId,
    required this.messageId,
    required this.alertSystemMessageId,
    required this.content,
    required this.matchedKeyword,
    required this.matchedContent,
  });
}
