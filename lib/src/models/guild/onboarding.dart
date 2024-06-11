import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template onboarding}
/// The configuration for a [Guild]'s onboarding process.
/// {@endtemplate}
class Onboarding with ToStringHelper {
  /// The manager for this [Onboarding].
  final GuildManager manager;

  /// The ID of the guild this onboarding is for.
  final Snowflake guildId;

  /// A list of prompts in this onboarding.
  final List<OnboardingPrompt> prompts;

  /// A list of channel IDs that get opted into automatically.
  final List<Snowflake> defaultChannelIds;

  /// Whether onboarding is enabled for this guild.
  final bool isEnabled;

  /// {@macro onboarding}
  /// @nodoc
  Onboarding({
    required this.manager,
    required this.guildId,
    required this.prompts,
    required this.defaultChannelIds,
    required this.isEnabled,
  });

  /// The guild this onboarding is for.
  PartialGuild get guild => manager.client.guilds[guildId];

  /// A list of channels that get opted into automatically.
  List<PartialChannel> get channels => defaultChannelIds.map((e) => manager.client.channels[e]).toList();
}

/// {@template onboarding_prompt}
/// A prompt in an [Onboarding] flow.
/// {@endtemplate}
class OnboardingPrompt with ToStringHelper {
  /// The ID of this prompt.
  final Snowflake id;

  /// The type of this prompt.
  final OnboardingPromptType type;

  /// The options available for this prompt.
  final List<OnboardingPromptOption> options;

  /// The title of this prompt.
  final String title;

  /// Whether the user can select at most one option.
  final bool isSingleSelect;

  /// Whether selecting an option is required.
  final bool isRequired;

  /// If this prompt appears in the onboarding flow.
  ///
  /// If `false`, this prompt will only be visible in the Roles & Channels tab of the Discord client.
  final bool isInOnboarding;

  /// {@macro onboarding_prompt}
  /// @nodoc
  OnboardingPrompt({
    required this.id,
    required this.type,
    required this.options,
    required this.title,
    required this.isSingleSelect,
    required this.isRequired,
    required this.isInOnboarding,
  });
}

/// The type of an [Onboarding] prompt.
final class OnboardingPromptType extends EnumLike<int> {
  static const multipleChoice = OnboardingPromptType._(0);
  static const dropdown = OnboardingPromptType._(1);

  static const List<OnboardingPromptType> values = [multipleChoice, dropdown];

  const OnboardingPromptType._(super.value);

  factory OnboardingPromptType.parse(int value) => parseEnum(values, value);
}

/// {@template onboarding_prompt_option}
/// An option in an [OnboardingPrompt].
/// {@endtemplate}
class OnboardingPromptOption with ToStringHelper {
  /// The manager for this [OnboardingPromptOption].
  final GuildManager manager;

  /// The ID of this option.
  final Snowflake id;

  /// The IDs of the channels the user is granted access to.
  final List<Snowflake> channelIds;

  /// The IDs of the roles the user is given.
  final List<Snowflake> roleIds;

  /// The emoji associated with this onboarding prompt.
  final Emoji? emoji;

  /// The title of this option.
  final String title;

  /// A description of this option.
  final String? description;

  /// {@macro onboarding_prompt_option}
  /// @nodoc
  OnboardingPromptOption({
    required this.manager,
    required this.id,
    required this.channelIds,
    required this.roleIds,
    required this.emoji,
    required this.title,
    required this.description,
  });

  /// The channels the user is granted access to.
  List<PartialChannel> get channels => channelIds.map((e) => manager.client.channels[e]).toList();
}
