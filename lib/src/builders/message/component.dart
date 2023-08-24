import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/message/component.dart';

abstract class MessageComponentBuilder extends CreateBuilder<MessageComponent> {
  MessageComponentType type;

  MessageComponentBuilder({required this.type});

  @override
  Map<String, Object?> build() => {'type': type.value};
}

class ActionRowBuilder extends MessageComponentBuilder {
  List<MessageComponentBuilder> components;

  ActionRowBuilder({required this.components}) : super(type: MessageComponentType.actionRow);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'components': components.map((e) => e.build()).toList(),
      };
}

class ButtonBuilder extends MessageComponentBuilder {
  ButtonStyle style;

  String? label;

  Emoji? emoji;

  String? customId;

  Uri? url;

  bool? isDisabled;

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
  String customId;

  List<SelectMenuOptionBuilder>? options;

  List<ChannelType>? channelTypes;

  String? placeholder;

  int? minValues;

  int? maxValues;

  bool? isDisabled;

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
  String label;

  String value;

  String? description;

  Emoji? emoji;

  bool? isDefault;

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
  String customId;

  TextInputStyle style;

  String label;

  int? minLength;

  int? maxLength;

  bool? isRequired;

  String? value;

  String? placeholder;

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
