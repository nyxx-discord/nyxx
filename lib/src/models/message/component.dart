import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// The type of a [MessageComponent].
enum MessageComponentType {
  actionRow._(1),
  button._(2),
  stringSelect._(3),
  textInput._(4),
  userSelect._(5),
  roleSelect._(6),
  mentionableSelect._(7),
  channelSelect._(8);

  /// The value of this [MessageComponentType].
  final int value;

  const MessageComponentType._(this.value);

  /// Parse a [MessageComponentType] from an [int].
  ///
  /// The [value] must be a valid message component type.
  factory MessageComponentType.parse(int value) => MessageComponentType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown message component type', value),
      );

  @override
  String toString() => 'MessageComponentType($value)';
}

/// A component in a [Message].
abstract class MessageComponent with ToStringHelper {
  /// The type of this component.
  MessageComponentType get type;
}

/// A [MessageComponent] that contains multiple child [MessageComponent]s.
class ActionRowComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.actionRow;

  /// The children of this [ActionRow].
  final List<MessageComponent> components;

  /// Create a new [ActionRowComponent].
  ActionRowComponent({required this.components});
}

/// A clickable button.
class ButtonComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.button;

  /// The style of this button.
  final ButtonStyle style;

  /// The label displayed on this button.
  final String? label;

  /// The [Emoji] displayed on this button.
  final Emoji? emoji;

  /// This component's custom ID.
  final String? customId;

  /// The URL this button redirects to, if this button is a URL button.
  final Uri? url;

  /// Whether this button is disabled.
  final bool? isDisabled;

  /// Create a new [ButtonComponent].
  ButtonComponent({
    required this.style,
    required this.label,
    required this.emoji,
    required this.customId,
    required this.url,
    required this.isDisabled,
  });
}

/// The style of a [ButtonComponent].
enum ButtonStyle {
  primary._(1),
  secondary._(2),
  success._(3),
  danger._(4),
  link._(5);

  /// The value of this [ButtonStyle].
  final int value;

  const ButtonStyle._(this.value);

  /// Parse a [ButtonStyle] from an [int].
  ///
  /// The [value] must be a valid button style.
  factory ButtonStyle.parse(int value) => ButtonStyle.values.firstWhere(
        (style) => style.value == value,
        orElse: () => throw FormatException('Unknown button style', value),
      );

  @override
  String toString() => 'ButtonStyle($value)';
}

/// A dropdown menu in which users can select from on or more choices.
class SelectMenuComponent extends MessageComponent {
  @override
  final MessageComponentType type;

  /// This component's custom ID.
  final String customId;

  /// The options in this menu.
  ///
  /// Will be `null` if this menu is not a [MessageComponentType.stringSelect] menu.
  final List<SelectMenuOption>? options;

  /// The channel types displayed in this select menu.
  ///
  /// Will be `null` if this menu is not a [MessageComponentType.channelSelect] menu.
  final List<ChannelType>? channelTypes;

  /// The placeholder shown when the user has not yet selected a value.
  final String? placeholder;

  /// The default selected values in this menu.
  final List<SelectMenuDefaultValue>? defaultValues;

  /// The minimum number of values the user must select.
  final int? minValues;

  /// The maximum number of values the user must select.
  final int? maxValues;

  /// Whether this component is disabled.
  final bool? isDisabled;

  /// Create a new [SelectMenuComponent].
  SelectMenuComponent({
    required this.type,
    required this.customId,
    required this.options,
    required this.channelTypes,
    required this.placeholder,
    required this.defaultValues,
    required this.minValues,
    required this.maxValues,
    required this.isDisabled,
  });
}

/// The type of a [SelectMenuDefaultValue].
enum SelectMenuDefaultValueType {
  user._('user'),
  role._('role'),
  channel._('channel');

  /// The value of this [SelectMenuDefaultValue].
  final String value;

  const SelectMenuDefaultValueType._(this.value);

  /// Parse a [SelectMenuDefaultValueType] from a [String].
  ///
  /// The [value] must be a valid select menu default value type.
  factory SelectMenuDefaultValueType.parse(String value) => SelectMenuDefaultValueType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown select menu default value type', value),
      );
}

/// A default value in a [SelectMenu].
class SelectMenuDefaultValue {
  /// The ID of this entity.
  final Snowflake id;

  /// The type of this entity.
  final SelectMenuDefaultValueType type;

  /// Create a new [SelectMenuDefaultValue].
  SelectMenuDefaultValue({required this.id, required this.type});
}

/// An option in a [SelectMenu].
class SelectMenuOption with ToStringHelper {
  /// The label shown to the user.
  final String label;

  /// The value sent to the application.
  final String value;

  /// The description of this option.
  final String? description;

  /// The emoji shown by this emoji.
  final Emoji? emoji;

  /// Whether this [SelectMenuOption] is selected by default.
  final bool? isDefault;

  /// Create a new [SelectMenuOption].
  SelectMenuOption({
    required this.label,
    required this.value,
    required this.description,
    required this.emoji,
    required this.isDefault,
  });
}

/// A text field in a modal.
class TextInputComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.textInput;

  /// This component's custom ID.
  final String customId;

  /// The style of this [TextInputComponent].
  final TextInputStyle? style;

  /// This component's label.
  final String? label;

  /// The minimum number of characters the user must input.
  final int? minLength;

  /// The maximum number of characters the user can input.
  final int? maxLength;

  /// Whether this component requires input.
  final bool? isRequired;

  /// The text contained in this component.
  final String? value;

  /// Placeholder text shown when this component is empty.
  final String? placeholder;

  /// Create a new [TextInputComponent].
  TextInputComponent({
    required this.customId,
    required this.style,
    required this.label,
    required this.minLength,
    required this.maxLength,
    required this.isRequired,
    required this.value,
    required this.placeholder,
  });
}

/// The type of a [TextInputComponent].
enum TextInputStyle {
  short._(1),
  paragraph._(2);

  /// The value of this [TextInputStyle].
  final int value;

  const TextInputStyle._(this.value);

  /// Parse a [TextInputComponent] from an [int].
  ///
  /// The [value] must beb a valid text input style.
  factory TextInputStyle.parse(int value) => TextInputStyle.values.firstWhere(
        (style) => style.value == value,
        orElse: () => throw FormatException('Unknown text input style', value),
      );

  @override
  String toString() => 'TextInputStyle($value)';
}
