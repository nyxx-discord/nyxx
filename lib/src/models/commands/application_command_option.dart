import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class CommandOption with ToStringHelper {
  final CommandOptionType type;

  final String name;

  final Map<Locale, String>? nameLocalizations;

  final String description;

  final Map<Locale, String>? descriptionLocalizations;

  final bool? isRequired;

  final List<CommandOptionChoice>? choices;

  final List<CommandOption>? options;

  final List<ChannelType>? channelTypes;

  final num? minValue;

  final num? maxValue;

  final int? minLength;

  final int? maxLength;

  final bool? hasAutocomplete;

  CommandOption({
    required this.type,
    required this.name,
    required this.nameLocalizations,
    required this.description,
    required this.descriptionLocalizations,
    required this.isRequired,
    required this.choices,
    required this.options,
    required this.channelTypes,
    required this.minValue,
    required this.maxValue,
    required this.minLength,
    required this.maxLength,
    required this.hasAutocomplete,
  });
}

enum CommandOptionType {
  subCommand._(1),
  subCommandGroup._(2),
  string._(3),
  integer._(4),
  boolean._(5),
  user._(6),
  channel._(7),
  role._(8),
  mentionable._(9),
  number._(10),
  attachment._(11);

  final int value;

  const CommandOptionType._(this.value);

  factory CommandOptionType.parse(int value) => CommandOptionType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown command option type', value),
      );

  @override
  String toString() => 'CommandOptionType($value)';
}

class CommandOptionChoice {
  final String name;

  final Map<Locale, String>? nameLocalizations;

  final dynamic value;

  CommandOptionChoice({required this.name, required this.nameLocalizations, required this.value});
}
