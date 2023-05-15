import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class Onboarding with ToStringHelper {
  final Snowflake guildId;

  final List<OnboardingPrompt> prompts;

  final List<Snowflake> defaultChannelIds;

  final bool isEnabled;

  Onboarding({
    required this.guildId,
    required this.prompts,
    required this.defaultChannelIds,
    required this.isEnabled,
  });
}

class OnboardingPrompt with ToStringHelper {
  final Snowflake id;

  final OnboardingPromptType type;

  final List<OnboardingPromptOption> options;

  final String title;

  final bool isSingleSelect;

  final bool isRequired;

  final bool isInOnboarding;

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

enum OnboardingPromptType {
  multipleChoice._(0),
  dropdown._(1);

  final int value;

  const OnboardingPromptType._(this.value);

  @override
  String toString() => 'OnboardingPromptType($value)';
}

class OnboardingPromptOption with ToStringHelper {
  final Snowflake id;

  final List<Snowflake> channelIds;

  final List<Snowflake> roleIds;

  // TODO
  //final Emoji emoji;

  final String title;

  final String? description;

  OnboardingPromptOption({
    required this.id,
    required this.channelIds,
    required this.roleIds,
    required this.title,
    required this.description,
  });
}
