import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

/// {@template auto_moderation_rule_create_event}
/// Emitted when an auto moderation rule is created.
/// {@endtemplate}
class AutoModerationRuleCreateEvent extends DispatchEvent {
  /// The rule that was created.
  final AutoModerationRule rule;

  /// {@macro auto_moderation_rule_create_event}
  AutoModerationRuleCreateEvent({required super.gateway, required this.rule});
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
  AutoModerationRuleUpdateEvent({required super.gateway, required this.oldRule, required this.rule});
}

/// {@template auto_moderation_rule_delete_event}
/// Emitted when an auto moderation rule is deleted.
/// {@endtemplate}
class AutoModerationRuleDeleteEvent extends DispatchEvent {
  /// The rule that was deleted.
  final AutoModerationRule rule;

  /// {@macro auto_moderation_rule_delete_event}
  AutoModerationRuleDeleteEvent({required super.gateway, required this.rule});
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
    required super.gateway,
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

  /// The guild the rule was triggered in.
  PartialGuild get guild => gateway.client.guilds[guildId];

  /// The rule that was triggered.
  PartialAutoModerationRule get rule => guild.autoModerationRules[ruleId];

  /// The user that triggered the rule.
  PartialUser get user => gateway.client.users[userId];

  /// The member that triggered the rule.
  PartialMember get member => guild.members[userId];

  /// The channel in which the rule was triggered.
  PartialChannel? get channel => channelId == null ? null : gateway.client.channels[channelId!];

  /// The message that triggered the rule.
  PartialMessage? get message => messageId == null ? null : (channel as PartialTextChannel?)?.messages[messageId!];
}
