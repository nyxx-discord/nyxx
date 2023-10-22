import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

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

  ButtonBuilder.primary({
    this.label,
    this.emoji,
    required this.customId,
    this.isDisabled,
  })  : style = ButtonStyle.primary,
        super(type: MessageComponentType.button);

  ButtonBuilder.secondary({
    this.label,
    this.emoji,
    required this.customId,
    this.isDisabled,
  })  : style = ButtonStyle.secondary,
        super(type: MessageComponentType.button);

  ButtonBuilder.success({
    this.label,
    this.emoji,
    required this.customId,
    this.isDisabled,
  })  : style = ButtonStyle.success,
        super(type: MessageComponentType.button);

  ButtonBuilder.danger({
    this.label,
    this.emoji,
    required this.customId,
    this.isDisabled,
  })  : style = ButtonStyle.danger,
        super(type: MessageComponentType.button);

  ButtonBuilder.link({
    this.label,
    this.emoji,
    required Uri this.url,
    this.isDisabled,
  })  : style = ButtonStyle.link,
        super(type: MessageComponentType.button);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'style': style.value,
        if (label != null) 'label': label,
        if (emoji != null)
          'emoji': {
            'id': emoji!.id == Snowflake.zero ? null : emoji!.id,
            'name': emoji!.name,
            if (emoji is GuildEmoji) 'animated': (emoji as GuildEmoji).isAnimated == true,
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

  List<DefaultValue>? defaultValues;

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
    this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  });

  SelectMenuBuilder.stringSelect({
    required this.customId,
    required List<SelectMenuOptionBuilder> this.options,
    this.placeholder,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  }) : super(type: MessageComponentType.stringSelect);

  SelectMenuBuilder.userSelect({
    required this.customId,
    this.placeholder,
    List<DefaultValue<User>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  }) : super(type: MessageComponentType.userSelect);

  SelectMenuBuilder.roleSelect({
    required this.customId,
    this.placeholder,
    List<DefaultValue<Role>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  }) : super(type: MessageComponentType.roleSelect);

  SelectMenuBuilder.mentionableSelect({
    required this.customId,
    this.channelTypes,
    this.placeholder,
    List<DefaultValue<CommandOptionMentionable>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  }) : super(type: MessageComponentType.mentionableSelect);

  SelectMenuBuilder.channelSelect({
    required this.customId,
    this.placeholder,
    List<DefaultValue<Channel>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
  }) : super(type: MessageComponentType.channelSelect);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'custom_id': customId,
        if (options != null) 'options': options?.map((e) => e.build()).toList(),
        if (channelTypes != null) 'channel_types': channelTypes?.map((e) => e.value).toList(),
        if (placeholder != null) 'placeholder': placeholder,
        if (defaultValues != null) 'default_values': defaultValues!.map((e) => e.build()).toList(),
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
            'id': emoji!.id.value,
            'name': emoji!.name,
            'animated': emoji is GuildEmoji && (emoji as GuildEmoji).isAnimated == true,
          },
        if (isDefault != null) 'default': isDefault,
      };
}

class DefaultValue<T extends SnowflakeEntity<T>> extends CreateBuilder<DefaultValue<T>> {
  Snowflake id;

  String type;

  DefaultValue({
    required this.id,
    required this.type,
  });

  static DefaultValue<User> user({required Snowflake id}) => DefaultValue(id: id, type: 'user');

  static DefaultValue<Role> role({required Snowflake id}) => DefaultValue(id: id, type: 'role');

  static DefaultValue<Channel> channel({required Snowflake id}) => DefaultValue(id: id, type: 'channel');

  @override
  Map<String, Object?> build() => {
        'id': id.toString(),
        'type': type,
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
        'label': label,
        if (minLength != null) 'min_length': minLength,
        if (maxLength != null) 'max_length': maxLength,
        if (isRequired != null) 'required': isRequired,
        if (placeholder != null) 'placeholder': placeholder,
      };
}
