import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/internal/exceptions/unknown_enum_value.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAutoModerationRule implements SnowflakeEntity {
  /// The guild's id this rule is applied to.
  Snowflake get guildId;

  /// The name of this rule.
  String get name;

  /// The user which first created this rule.
  Snowflake get creatorId;

  /// The rule event type.
  EventTypes get eventType;

  /// The rule trigger type.
  TriggerTypes get triggerType;

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
        throw UnknownEnumValue(value.toString());
    }
  }

  @override
  String toString() => 'EventTypes[$value]';
}

enum TriggerTypes {
  /// Check if content contains words from a user defined list of keywords.
  keyword(1),

  /// Check if content contains any harmful links.
  harmfulLink(2),

  /// Check if content represents generic spam.
  spam(3),

  /// Check if content contains words from internal pre-defined wordsets.
  keywordPreset(4),

  /// Check if content contains more mentions than allowed.
  mentionSpam(5);

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
        throw UnknownEnumValue(value.toString());
    }
  }

  @override
  String toString() => 'TriggerTypes[$value]';
}

enum KeywordPresets {
  /// Words that may be considered forms of swearing or cursing.
  profanity(1),

  /// Words that refer to sexually explicit behavior or activity.
  sexualContent(2),

  /// Personal insults or words that may be considered hate speech.
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
        throw UnknownEnumValue(value.toString());
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
        throw UnknownEnumValue(value.toString());
    }
  }

  @override
  String toString() => 'ActionTypes[$value]';
}

abstract class ITriggerMetadata {
  /// Substrings wich will be searched for in the content.
  /// The associated trigger type is [TriggerTypes.keyword].
  List<String>? get keywordsFilter;

  /// The internally pre-defined wordsets which will be searched for in content.
  /// The associated trigger type is [TriggerTypes.keywordPreset].
  List<KeywordPresets> get keywordPresets;

  /// Substrings which will be exempt from triggering the preset trigger type.
  /// The associated trigger type is [TriggerTypes.keywordPreset].
  List<String> get allowList;
}

abstract class IActionStructure {
  /// The type of the action.
  ActionTypes get actionType;

  /// Additionnal metadata needed during execution for this specific action type.
  IActionMetadata? get actionMetadata;
}

abstract class IActionMetadata {
  /// The channel if to wich user content should be logged.
  /// The associated action type is [ActionTypes.sendAlertMessage].
  Snowflake? get channelId;

  /// The timeout duration - maximum duration is 4 weeks (2,419,200 seconds).
  /// It's associated action type is [ActionTypes.timeout].
  Duration? get duration;
}

class AutoModerationRule extends SnowflakeEntity implements IAutoModerationRule {
  @override
  late final Snowflake guildId;

  @override
  late final String name;

  @override
  late final Snowflake creatorId;

  @override
  late final EventTypes eventType;

  @override
  late final TriggerTypes triggerType;

  @override
  late final ITriggerMetadata triggerMetadata;

  @override
  late final List<IActionStructure> actions;

  @override
  late final bool enabled;

  @override
  late final List<Snowflake> ignoredRoles;

  @override
  late final List<Snowflake> ignoredChannels;

  AutoModerationRule(RawApiMap rawData) : super(Snowflake(rawData['id'])) {
    guildId = Snowflake(rawData['guild_id']);
    name = rawData['name'] as String;
    creatorId = Snowflake(rawData['creator_id']);
    eventType = EventTypes._fromValue(rawData['event_type'] as int);
    triggerType = TriggerTypes._fromValue(rawData['trigger_type'] as int);
    triggerMetadata = TriggerMetadata(rawData['trigger_metadata'] as RawApiMap);
    actions = [...?(rawData['actions'] as RawApiList?)?.map((a) => ActionStructure(a as RawApiMap))];
    enabled = rawData['enabled'] as bool;
    ignoredRoles = (rawData['exempt_roles'] as RawApiList).isNotEmpty ? [...(rawData['exempt_roles'] as RawApiList).map((r) => Snowflake(r))] : [];
    ignoredChannels = (rawData['exempt_channels'] as RawApiList).isNotEmpty ? [...(rawData['exempt_channels'] as RawApiList).map((r) => Snowflake(r))] : [];
  }
}

class TriggerMetadata implements ITriggerMetadata {
  // Maybe return null instead of empty list
  @override
  late final List<KeywordPresets> keywordPresets;

  @override
  late final List<String>? keywordsFilter;

  @override
  late final List<String> allowList;

  /// Creates an instance of [TriggerMetadata]
  TriggerMetadata(RawApiMap data) {
    keywordsFilter = data['keyword_filter'] != null ? [...data['keyword_filter']] : null;
    keywordPresets = [...?(data['presets'] as List<int>?)?.map((p) => KeywordPresets._fromValue(p))];
    allowList = (data['allow_list'] as List<String>);
  }
}

class ActionStructure implements IActionStructure {
  @override
  late final IActionMetadata? actionMetadata;

  @override
  late final ActionTypes actionType;

  /// Creates an instance of [ActionStructure].
  ActionStructure(RawApiMap data) {
    actionType = ActionTypes._fromValue(data['type'] as int);
    // TODO: Refactor this with an if statement
    actionMetadata = (data['metadata'] != null && (data['metadata'] as RawApiMap).isNotEmpty) ? ActionMetadata(data['metadata'] as RawApiMap) : null;
  }
}

class ActionMetadata implements IActionMetadata {
  @override
  late final Snowflake? channelId;

  @override
  late final Duration? duration;

  /// Creates an instance of [ActionMetadata].
  ActionMetadata(RawApiMap data) {
    channelId = data['channel_id'] != null ? Snowflake(data['channel_id']) : null;
    duration = data['duration_seconds'] != null ? Duration(seconds: data['duration_seconds'] as int) : null;
  }
}
