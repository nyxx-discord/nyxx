import 'package:nyxx/src/core/channel/guild/text_guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/exceptions/unknown_enum_value.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IAutoModerationRule implements SnowflakeEntity {
  /// The guild's id this rule is applied to.
  Cacheable<Snowflake, IGuild> get guild;

  /// The name of this rule.
  String get name;

  /// The user which first created this rule.
  Cacheable<Snowflake, IMember> get creator;

  /// The rule event type.
  EventTypes get eventType;

  /// The rule trigger type.
  TriggerTypes get triggerType;

  /// The trigger metadata.
  ITriggerMetadata get triggerMetadata;

  /// The actions which will execute when the rule is triggered.
  List<IActionStructure>? get actions;

  /// Whether this rule is enabled.
  bool get enabled;

  /// The role that should not be affected by the rule (Maximum of 20).
  Iterable<Cacheable<Snowflake, IRole>> get ignoredRoles;

  /// The channel that should not be affected by the rule (Maximum of 50).
  Iterable<Cacheable<Snowflake, ITextGuildChannel>> get ignoredChannels;
}

enum EventTypes {
  /// When a member sends or edits a message in a guild.
  messageSend(1);

  final int value;
  const EventTypes(this.value);

  static EventTypes _fromValue(int value) => values.firstWhere((v) => v.value == value, orElse: () => throw UnknownEnumValue(value));

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

  // Not private because used in guild events
  static TriggerTypes fromValue(int value) => values.firstWhere((v) => v.value == value, orElse: () => throw UnknownEnumValue(value));

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

  static KeywordPresets _fromValue(int value) => values.firstWhere((v) => v.value == value, orElse: () => throw UnknownEnumValue(value));

  @override
  String toString() => 'KeywordPresets[$value]';
}

enum ActionTypes {
  /// Blocks the content of a message according to the rule.
  blockMessage(1),

  /// Logs user's sended message to a specified channel.
  sendAlertMessage(2),

  /// Timeout user for a specified duration.
  timeout(3);

  final int value;
  const ActionTypes(this.value);

  static ActionTypes _fromValue(int value) => values.firstWhere((v) => v.value == value, orElse: () => throw UnknownEnumValue(value));

  @override
  String toString() => 'ActionTypes[$value]';
}

abstract class ITriggerMetadata {
  /// Substrings wich will be searched for in the content.
  /// The associated trigger type is [TriggerTypes.keyword].
  List<String>? get keywordsFilter;

  /// The internally pre-defined wordsets which will be searched for in content.
  /// The associated trigger type is [TriggerTypes.keywordPreset].
  List<KeywordPresets>? get keywordPresets;

  /// Substrings which will be exempt from triggering the preset trigger type.
  /// The associated trigger type is [TriggerTypes.keywordPreset].
  List<String>? get allowList;

  /// The total number of mentions (either role and user) allowed per message.
  /// (Maximum of 50)
  /// The associated trigger type is [TriggerTypes.mentionSpam]
  // Pr still not merged
  int? get mentionLimit;
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
  Cacheable<Snowflake, ITextGuildChannel>? get channelId;

  /// The timeout duration - maximum duration is 4 weeks (2,419,200 seconds).
  /// It's associated action type is [ActionTypes.timeout].
  Duration? get duration;
}

class AutoModerationRule extends SnowflakeEntity implements IAutoModerationRule {
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  @override
  late final String name;

  @override
  late final Cacheable<Snowflake, IMember> creator;

  @override
  late final EventTypes eventType;

  @override
  late final TriggerTypes triggerType;

  @override
  late final ITriggerMetadata triggerMetadata;

  @override
  late final List<IActionStructure>? actions;

  @override
  late final bool enabled;

  @override
  late final Iterable<Cacheable<Snowflake, IRole>> ignoredRoles;

  @override
  late final Iterable<Cacheable<Snowflake, ITextGuildChannel>> ignoredChannels;

  AutoModerationRule(RawApiMap rawData, INyxx client) : super(Snowflake(rawData['id'])) {
    guild = GuildCacheable(client, Snowflake(rawData['guild_id']));
    name = rawData['name'] as String;
    creator = MemberCacheable(client, Snowflake(rawData['creator_id']), guild);
    eventType = EventTypes._fromValue(rawData['event_type'] as int);
    triggerType = TriggerTypes.fromValue(rawData['trigger_type'] as int);
    triggerMetadata = TriggerMetadata(rawData['trigger_metadata'] as RawApiMap);
    actions = (rawData['actions'] as RawApiList?)?.map((a) => ActionStructure(a as RawApiMap, client)).toList();
    enabled = rawData['enabled'] as bool;
    ignoredRoles = (rawData['exempt_roles'] as RawApiList).isNotEmpty
        ? (rawData['exempt_roles'] as RawApiList).map((r) => RoleCacheable(client, Snowflake(r), guild))
        : [];
    ignoredChannels = (rawData['exempt_channels'] as RawApiList).isNotEmpty
        ? (rawData['exempt_channels'] as RawApiList).map((r) => ChannelCacheable(client, Snowflake(r)))
        : [];
  }

  @override
  String toString() => 'IAutoModerationRule(id: $id, guildId: ${guild.id}, name: $name, triggerMetadata: $triggerMetadata)';
}

class TriggerMetadata implements ITriggerMetadata {
  // Maybe return null instead of empty list
  @override
  late final List<KeywordPresets>? keywordPresets;

  @override
  late final List<String>? keywordsFilter;

  @override
  late final List<String>? allowList;

  @override
  late final int? mentionLimit;

  /// Creates an instance of [TriggerMetadata]
  TriggerMetadata(RawApiMap data) {
    keywordsFilter = data['keyword_filter'] != null ? (data['keyword_filter'] as RawApiList).cast<String>() : null;
    keywordPresets = data['presets'] != null ? [...(data['presets'] as RawApiList).map((p) => KeywordPresets._fromValue(p as int))] : null;
    allowList = (data['allow_list'] as RawApiList?)?.cast<String>().toList();
    mentionLimit = data['mention_total_limit'] as int?;
  }

  @override
  String toString() => 'ITriggerMetadata(keywordPresets: $keywordPresets, keywordFilter: $keywordsFilter, allowList: $allowList, mentionLimit: $mentionLimit)';
}

class ActionStructure implements IActionStructure {
  @override
  late final IActionMetadata? actionMetadata;

  @override
  late final ActionTypes actionType;

  /// Creates an instance of [ActionStructure].
  ActionStructure(RawApiMap data, INyxx client) {
    actionType = ActionTypes._fromValue(data['type'] as int);
    if (data['metadata'] != null && (data['metadata'] as RawApiMap).isNotEmpty) {
      actionMetadata = ActionMetadata(data['metadata'] as RawApiMap, client);
    } else {
      actionMetadata = null;
    }
  }
}

class ActionMetadata implements IActionMetadata {
  @override
  late final Cacheable<Snowflake, ITextGuildChannel>? channelId;

  @override
  late final Duration? duration;

  /// Creates an instance of [ActionMetadata].
  ActionMetadata(RawApiMap data, INyxx client) {
    channelId = data['channel_id'] != null ? ChannelCacheable(client, Snowflake(data['channel_id'])) : null;
    duration = data['duration_seconds'] != null ? Duration(seconds: data['duration_seconds'] as int) : null;
  }
}
