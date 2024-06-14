import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template command_option}
/// An option in an [ApplicationCommand] with a type of [ApplicationCommandType.chatInput].
/// {@endtemplate}
class CommandOption with ToStringHelper {
  /// The type of this option.
  final CommandOptionType type;

  /// The name of this option.
  final String name;

  /// A localized map of names for this option.
  final Map<Locale, String>? nameLocalizations;

  /// The description of this option.
  final String description;

  /// A localized map of descriptions for this option.
  final Map<Locale, String>? descriptionLocalizations;

  /// Whether this option is required.
  final bool? isRequired;

  /// The choices available for this option.
  final List<CommandOptionChoice>? choices;

  /// If this option is a subcommand, the options of the subcommand.
  final List<CommandOption>? options;

  /// The types of channel that can be selected.
  final List<ChannelType>? channelTypes;

  /// The minimum value for this option.
  final num? minValue;

  /// The maximum value for this option.
  final num? maxValue;

  /// The minimum length for this option.
  final int? minLength;

  /// The maximum length for this option.
  final int? maxLength;

  /// Whether this option has autocompletion.
  final bool? hasAutocomplete;

  /// {@macro command_option}
  /// @nodoc
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

/// The type of a [CommandOption].
final class CommandOptionType extends EnumLike<int, CommandOptionType> {
  static const subCommand = CommandOptionType(1);
  static const subCommandGroup = CommandOptionType(2);
  static const string = CommandOptionType(3);
  static const integer = CommandOptionType(4);
  static const boolean = CommandOptionType(5);
  static const user = CommandOptionType(6);
  static const channel = CommandOptionType(7);
  static const role = CommandOptionType(8);
  static const mentionable = CommandOptionType(9);
  static const number = CommandOptionType(10);
  static const attachment = CommandOptionType(11);

  /// @nodoc
  const CommandOptionType(super.value);

  CommandOptionType.parse(int value) : this(value);
}

/// {@template command_option_choice}
/// A choice for a [CommandOption].
/// {@endtemplate}
class CommandOptionChoice {
  /// The name of this choice.
  final String name;

  /// A localized map of names for this choice.
  final Map<Locale, String>? nameLocalizations;

  /// The value of this choice.
  final dynamic value;

  /// {@macro command_option_choice}
  /// @nodoc
  CommandOptionChoice({required this.name, required this.nameLocalizations, required this.value});
}

/// A common superclass for entities that can be passed in options of type [CommandOptionType.mentionable].
///
/// The only subtypes are [User] and [Role].
abstract interface class CommandOptionMentionable<T extends CommandOptionMentionable<T>> implements SnowflakeEntity<T> {}
