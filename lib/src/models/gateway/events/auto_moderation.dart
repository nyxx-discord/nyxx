import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

class AutoModerationRuleCreateEvent extends DispatchEvent {
  // TODO
  //final AutoModerationRule rule;
}

class AutoModerationRuleUpdateEvent extends DispatchEvent {
  // TODO
  //final AutoModerationRule rule;
}

class AutoModerationRuleDeleteEvent extends DispatchEvent {
  // TODO
  //final AutoModerationRule rule;
}

class AutoModerationActionExecutionEvent extends DispatchEvent {
  final Snowflake guildId;

  // TODO
  //final AutoModerationAction action;

  final Snowflake ruleId;

  // TODO
  //final TriggerType triggerType;

  final Snowflake userId;

  final Snowflake? channelId;

  final Snowflake? messageId;

  final Snowflake? alertSystemMessageId;

  final String? content;

  final String? matchedKeyword;

  final String? matchedContent;

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
