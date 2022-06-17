import 'package:nyxx/src/core/snowflake.dart';

abstract class IAutoModerationRule {
  /// The id of this rule.
  Snowflake get id;

  /// The guild's id this rule is applied to.
  Snowflake get guildId;

  /// The name of this rule.
  String get name;

  /// The user which first created this rule.
  Snowflake get creatorId;

  /// The rule event type.
  EventTypes get eventTypes;

  /// The rule trigger type.
  TriggerTypes get triggerTypes;

  /// The trigger metadata.
  ITriggerMetadata get triggerMetadata;

  /// The actions which will execute when the rule is triggered.
  List<IActionStructure> get actions;

  /// Whether this rule is enabled.
  bool get enabled;

  /// The role ids that should not be affected by the rule (Maximum of 20).
  List<Snowflake> get ignoredRoles;

  /// The channel ids that should not be affected by the rule (Maximum of 50).
  List<Snowflake> get ignoredChannels;
}

enum EventTypes {
  messageSend(1);

  final int value;
  const EventTypes(this.value);

  static EventTypes _fromValue(int value) {
    switch (value) {
      case 1:
        return EventTypes.messageSend;
      default:
        throw Exception('Unknown enum value: $value');
    }
  }

  @override
  String toString() => 'EventTypes[$value]';
}

enum TriggerTypes {
  /// Check if content contains words from a user defined list of keywords
  keyword(1),

  /// Check if content contains any harmful links
  harmfulLink(2),

  /// Check if content represents generic spam
  spam(3),

  /// Check if content contains words from internal pre-defined wordsets
  keywordPreset(4);

  final int value;
  const TriggerTypes(this.value);

  static TriggerTypes _fromValue(int value) {
    switch (value) {
      case 1:
        return TriggerTypes.keyword;
      case 2:
        return TriggerTypes.harmfulLink;
      case 3:
        return TriggerTypes.spam;
      case 4:
        return TriggerTypes.keywordPreset;
      default:
        throw Exception('Unknown enum value: $value');
    }
  }

  @override
  String toString() => 'TriggerTypes[$value]';
}

enum KeywordPresets {
  /// Words that may be considered forms of swearing or cursing
  profanity(1),

  /// Words that refer to sexually explicit behavior or activity
  sexualContent(2),

  /// Personal insults or words that may be considered hate speech
  slurs(3);

  final int value;
  const KeywordPresets(this.value);

  static KeywordPresets _fromValue(int value) {
    switch (value) {
      case 1:
        return KeywordPresets.profanity;
      case 2:
        return KeywordPresets.sexualContent;
      case 3:
        return KeywordPresets.slurs;
      default:
        throw Exception('Unknown enum value: $value');
    }
  }

  @override
  String toString() => 'KeywordPresets[$value]';
}

enum ActionTypes {
  blockMessage(1),
  sendAlertMessage(2),
  timeout(3);

  final int value;
  const ActionTypes(this.value);

  static ActionTypes _fromValue(int value) {
    switch (value) {
      case 1:
        return ActionTypes.blockMessage;
      case 2:
        return ActionTypes.sendAlertMessage;
      case 3:
        return ActionTypes.timeout;
      default:
        throw Exception('Unknown enum value: $value');
    }
  }

  @override
  String toString() => 'ActionTypes[$value]';
}

abstract class ITriggerMetadata {
  /// Substrings wich will be searched for in the content.
  /// The associated trigger type is [TriggerTypes.keyword].
  List<String> get keywordsFilter;

  /// The internally pre-defined wordsets which will be searched for in content.
  /// The associated trigger type is [TriggerTypes.keywordPreset].
  List<KeywordPresets> get keywordPresets;
}

abstract class IActionStructure {
  /// The type of the action.
  ActionTypes get actionType;

  /// Additionnal metadata needed during execution for this specific action type.
  IActionMetadata get actionMetadata;
}

abstract class IActionMetadata {
  /// The channel if to wich user content should be logged.
  /// The associated action type is [ActionTypes.sendAlertMessage].
  Snowflake get channelId;

  /// The timeout duration - maximum duration is 4 weeks (2,419,200 seconds).
  /// It's associated action type is [ActionTypes.timeout].
  Duration get duration;
}
