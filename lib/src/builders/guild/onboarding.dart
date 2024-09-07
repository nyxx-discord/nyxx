import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/guild/onboarding.dart';
import 'package:nyxx/src/models/snowflake.dart';

class OnboardingUpdateBuilder extends UpdateBuilder<Onboarding> {
  List<OnboardingPromptBuilder> prompts;

  List<Snowflake> defaultChannelIds;

  bool isEnabled;

  OnboardingMode mode;

  OnboardingUpdateBuilder({
    required this.prompts,
    required this.defaultChannelIds,
    required this.isEnabled,
    required this.mode,
  });

  @override
  Map<String, Object?> build() => {
        'prompts': prompts.map((prompt) => prompt.build()).toList(),
        'default_channel_ids': defaultChannelIds.map((channelId) => channelId.toString()).toList(),
        'enabled': isEnabled,
        'mode': mode.value,
      };
}

class OnboardingPromptBuilder extends CreateBuilder<OnboardingPrompt> {
  OnboardingPromptType type;

  List<OnboardingPromptOptionBuilder> options;

  String title;

  bool isSingleSelect;

  bool isRequired;

  bool isInOnboarding;

  OnboardingPromptBuilder({
    required this.type,
    required this.options,
    required this.title,
    required this.isSingleSelect,
    required this.isRequired,
    required this.isInOnboarding,
  });

  @override
  Map<String, Object?> build() => {
        'type': type.value,
        'options': options.map((option) => option.build()).toList(),
        'title': title,
        'single_select': isSingleSelect,
        'required': isRequired,
        'in_onboarding': isInOnboarding,
      };
}

class OnboardingPromptOptionBuilder extends CreateBuilder<OnboardingPromptOption> {
  List<Snowflake> channelIds;

  List<Snowflake> roleIds;

  Emoji? emoji;

  String title;

  String? description;

  OnboardingPromptOptionBuilder({
    required this.channelIds,
    required this.roleIds,
    this.emoji,
    required this.title,
    this.description,
  });

  @override
  Map<String, Object?> build() => {
        'channel_ids': channelIds.map((id) => id.toString()).toList(),
        'role_ids': roleIds.map((id) => id.toString()).toList(),
        if (emoji case final emoji?) 'emoji_name': emoji.name,
        if (emoji case GuildEmoji emoji) ...{
          'emoji_id': emoji.id,
          'emoji_animated': emoji.isAnimated,
        },
        'title': title,
        'description': description,
      };
}
