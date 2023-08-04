import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/message/component.dart';

abstract class MessageComponentBuilder extends CreateBuilder<MessageComponent> {
  final MessageComponentType type;

  MessageComponentBuilder({required this.type});

  @override
  Map<String, Object?> build() => {'type': type.value};
}

class ActionRowBuilder extends MessageComponentBuilder {
  final List<MessageComponentBuilder> components;

  ActionRowBuilder({required this.components}) : super(type: MessageComponentType.actionRow);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'components': components.map((e) => e.build()).toList(),
      };
}

class ButtonBuilder extends MessageComponentBuilder {
  final ButtonStyle style;

  final String? label;

  final Emoji? emoji;

  final String? customId;

  final Uri? url;

  final bool? isDisabled;

  ButtonBuilder({
    required this.style,
    this.label,
    this.emoji,
    this.customId,
    this.url,
    this.isDisabled,
  }) : super(type: MessageComponentType.button);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'style': style.value,
        if (label != null) 'label': label,
        if (emoji != null)
          'emoji': {
            'id': emoji!.id,
            'name': emoji!.name,
            'animated': emoji is GuildEmoji && (emoji as GuildEmoji).isAnimated == true,
          },
        if (customId != null) 'custom_id': customId,
        if (url != null) 'url': url!.toString(),
        if (isDisabled != null) 'disabled': isDisabled,
      };
}

class SelectMenuBuilder extends MessageComponentBuilder {
  final String customId;

  final List<SelectMenuOptionBuilder>? options;

  final List<ChannelType>? channelTypes;

  final String? placeholder;

  final int? minValues;

  final int? maxValues;

  final bool? isDisabled;

  SelectMenuBuilder({
    required super.type,
    required this.customId,
    this.options,
    this.channelTypes,
    this.placeholder,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  });

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'custom_id': customId,
        if (options != null) 'options': options?.map((e) => e.build()).toList(),
        if (channelTypes != null) 'channel_types': channelTypes?.map((e) => e.value).toList(),
        if (placeholder != null) 'placeholder': placeholder,
        if (minValues != null) 'min_values': minValues,
        if (maxValues != null) 'max_values': maxValues,
        if (isDisabled != null) 'disabled': isDisabled,
      };
}

class SelectMenuOptionBuilder extends CreateBuilder<SelectMenuOption> {
  final String label;

  final String value;

  final String? description;

  final Emoji? emoji;

  final bool? isDefault;

  SelectMenuOptionBuilder({
    required this.label,
    required this.value,
    this.description,
    this.emoji,
    this.isDefault,
  });

  @override
  Map<String, Object?> build() => {
        'label': label,
        'value': value,
        if (description != null) 'description': description,
        if (emoji != null)
          'emoji': {
            'id': emoji!.id,
            'name': emoji!.name,
            'animated': emoji is GuildEmoji && (emoji as GuildEmoji).isAnimated == true,
          },
        if (isDefault != null) 'default': isDefault,
      };
}

class TextInputBuilder extends MessageComponentBuilder {
  final String customId;

  final TextInputStyle style;

  final String label;

  final int? minLength;

  final int? maxLength;

  final bool? isRequired;

  final String? value;

  final String? placeholder;

  TextInputBuilder({
    required this.customId,
    required this.style,
    required this.label,
    this.minLength,
    this.maxLength,
    this.isRequired,
    this.value,
    this.placeholder,
  }) : super(type: MessageComponentType.textInput);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'custom_id': customId,
        'style': style.value,
        if (minLength != null) 'min_length': minLength,
        if (maxLength != null) 'max_length': maxLength,
        if (isRequired != null) 'required': isRequired,
        if (placeholder != null) 'placeholder': placeholder,
      };
}
