import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

enum MessageComponentType {
  actionRow._(1),
  button._(2),
  stringSelect._(3),
  textInput._(4),
  userSelect._(5),
  roleSelect._(6),
  mentionableSelect._(7),
  channelSelect._(8);

  final int value;

  const MessageComponentType._(this.value);

  factory MessageComponentType.parse(int value) => MessageComponentType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown message component type', value),
      );

  @override
  String toString() => 'MessageComponentType($value)';
}

abstract class MessageComponent with ToStringHelper {
  MessageComponentType get type;
}

class ActionRowComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.actionRow;

  final List<MessageComponent> components;

  ActionRowComponent({required this.components});
}

class ButtonComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.button;

  final ButtonStyle style;

  final String? label;

  final Emoji? emoji;

  final String? customId;

  final Uri? url;

  final bool? isDisabled;

  ButtonComponent({
    required this.style,
    required this.label,
    required this.emoji,
    required this.customId,
    required this.url,
    required this.isDisabled,
  });
}

enum ButtonStyle {
  primary._(1),
  secondary._(2),
  success._(3),
  danger._(4),
  link._(5);

  final int value;

  const ButtonStyle._(this.value);

  factory ButtonStyle.parse(int value) => ButtonStyle.values.firstWhere(
        (style) => style.value == value,
        orElse: () => throw FormatException('Unknown button style', value),
      );

  @override
  String toString() => 'ButtonStyle($value)';
}

class SelectMenuComponent extends MessageComponent {
  @override
  final MessageComponentType type;

  final String customId;

  final List<SelectMenuOption>? options;

  final List<ChannelType>? channelTypes;

  final String? placeholder;

  final int? minValues;

  final int? maxValues;

  final bool? isDisabled;

  SelectMenuComponent({
    required this.type,
    required this.customId,
    required this.options,
    required this.channelTypes,
    required this.placeholder,
    required this.minValues,
    required this.maxValues,
    required this.isDisabled,
  });
}

class SelectMenuOption with ToStringHelper {
  final String label;

  final String value;

  final String? description;

  final Emoji? emoji;

  final bool? isDefault;

  SelectMenuOption({
    required this.label,
    required this.value,
    required this.description,
    required this.emoji,
    required this.isDefault,
  });
}

class TextInputComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.textInput;

  final String customId;

  final TextInputStyle? style;

  final String? label;

  final int? minLength;

  final int? maxLength;

  final bool? isRequired;

  final String? value;

  final String? placeholder;

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

enum TextInputStyle {
  short._(1),
  paragraph._(2);

  final int value;

  const TextInputStyle._(this.value);

  factory TextInputStyle.parse(int value) => TextInputStyle.values.firstWhere(
        (style) => style.value == value,
        orElse: () => throw FormatException('Unknown text input style', value),
      );

  @override
  String toString() => 'TextInputStyle($value)';
}
