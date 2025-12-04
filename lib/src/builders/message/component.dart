import 'package:meta/meta.dart';
import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

abstract class MessageComponentBuilder<T extends MessageComponent> extends CreateBuilder<T> {
  MessageComponentType type;

  int? id;

  MessageComponentBuilder({required this.type, this.id});

  @override
  @mustBeOverridden
  Map<String, Object?> build() => {'type': type.value, 'id': id};
}

class ActionRowBuilder extends MessageComponentBuilder<ActionRowComponent> {
  List<MessageComponentBuilder> components;

  ActionRowBuilder({required this.components}) : super(type: MessageComponentType.actionRow);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'components': components.map((e) => e.build()).toList(),
      };
}

class ButtonBuilder extends MessageComponentBuilder<ButtonComponent> {
  ButtonStyle style;

  String? label;

  Emoji? emoji;

  String? customId;

  Snowflake? skuId;

  Uri? url;

  bool? isDisabled;

  ButtonBuilder({
    required this.style,
    this.label,
    this.emoji,
    this.customId,
    this.skuId,
    this.url,
    this.isDisabled,
    super.id,
  }) : super(type: MessageComponentType.button);

  ButtonBuilder.primary({
    this.label,
    this.emoji,
    required String this.customId,
    this.isDisabled,
    super.id,
  })  : style = ButtonStyle.primary,
        super(type: MessageComponentType.button);

  ButtonBuilder.secondary({
    this.label,
    this.emoji,
    required String this.customId,
    this.isDisabled,
    super.id,
  })  : style = ButtonStyle.secondary,
        super(type: MessageComponentType.button);

  ButtonBuilder.success({
    this.label,
    this.emoji,
    required String this.customId,
    this.isDisabled,
    super.id,
  })  : style = ButtonStyle.success,
        super(type: MessageComponentType.button);

  ButtonBuilder.danger({
    this.label,
    this.emoji,
    required String this.customId,
    this.isDisabled,
    super.id,
  })  : style = ButtonStyle.danger,
        super(type: MessageComponentType.button);

  ButtonBuilder.link({
    this.label,
    this.emoji,
    required Uri this.url,
    this.isDisabled,
    super.id,
  })  : style = ButtonStyle.link,
        super(type: MessageComponentType.button);

  ButtonBuilder.premium({
    required Snowflake this.skuId,
    this.isDisabled,
    super.id,
  })  : style = ButtonStyle.premium,
        super(type: MessageComponentType.button);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'style': style.value,
        if (label != null) 'label': label,
        if (emoji != null)
          'emoji': {
            'id': emoji!.id == Snowflake.zero ? null : emoji!.id.toString(),
            'name': emoji!.name,
            if (emoji is GuildEmoji) 'animated': (emoji as GuildEmoji).isAnimated == true,
          },
        if (customId != null) 'custom_id': customId,
        if (skuId != null) 'sku_id': skuId.toString(),
        if (url != null) 'url': url!.toString(),
        if (isDisabled != null) 'disabled': isDisabled,
      };
}

class SelectMenuBuilder extends MessageComponentBuilder<SelectMenuComponent> {
  String customId;

  List<SelectMenuOptionBuilder>? options;

  List<ChannelType>? channelTypes;

  List<DefaultValue>? defaultValues;

  String? placeholder;

  int? minValues;

  int? maxValues;

  bool? isDisabled;

  bool? isRequired;

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
    super.id,
  });

  SelectMenuBuilder.stringSelect({
    required this.customId,
    required List<SelectMenuOptionBuilder> this.options,
    this.placeholder,
    this.minValues,
    this.maxValues,
    this.isDisabled,
    super.id,
    this.isRequired,
  }) : super(type: MessageComponentType.stringSelect);

  SelectMenuBuilder.userSelect({
    required this.customId,
    this.placeholder,
    List<DefaultValue<User>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
    super.id,
    this.isRequired,
  }) : super(type: MessageComponentType.userSelect);

  SelectMenuBuilder.roleSelect({
    required this.customId,
    this.placeholder,
    List<DefaultValue<Role>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
    super.id,
    this.isRequired,
  }) : super(type: MessageComponentType.roleSelect);

  SelectMenuBuilder.mentionableSelect({
    required this.customId,
    this.channelTypes,
    this.placeholder,
    List<DefaultValue<CommandOptionMentionable>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
    super.id,
    this.isRequired,
  }) : super(type: MessageComponentType.mentionableSelect);

  SelectMenuBuilder.channelSelect({
    required this.customId,
    this.placeholder,
    List<DefaultValue<Channel>>? this.defaultValues,
    this.minValues,
    this.maxValues,
    this.isDisabled,
    super.id,
    this.isRequired,
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
        if (isRequired != null) 'required': isRequired,
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
            'id': emoji!.id.toString(),
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

class TextInputBuilder extends MessageComponentBuilder<SubmittedTextInputComponent> {
  String customId;

  TextInputStyle style;

  @Deprecated('Use Label components instead')
  // TODO(abitofevrything) This should be nullable.
  String label;

  int? minLength;

  int? maxLength;

  bool? isRequired;

  String? value;

  String? placeholder;

  TextInputBuilder({
    required this.customId,
    required this.style,
    this.label = sentinelString,
    this.minLength,
    this.maxLength,
    this.isRequired,
    this.value,
    this.placeholder,
    super.id,
  }) : super(type: MessageComponentType.textInput);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'custom_id': customId,
        'style': style.value,
        // ignore: deprecated_member_use_from_same_package
        if (!identical(label, sentinelString)) 'label': label,
        if (minLength != null) 'min_length': minLength,
        if (maxLength != null) 'max_length': maxLength,
        if (isRequired != null) 'required': isRequired,
        if (value != null) 'value': value,
        if (placeholder != null) 'placeholder': placeholder,
      };
}

class SectionComponentBuilder extends MessageComponentBuilder<SectionComponent> {
  List<TextDisplayComponentBuilder> components;

  MessageComponentBuilder accessory;

  SectionComponentBuilder({super.id, required this.components, required this.accessory}) : super(type: MessageComponentType.section);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'components': [for (final component in components) component.build()],
        'accessory': accessory.build(),
      };
}

class TextDisplayComponentBuilder extends MessageComponentBuilder<TextDisplayComponent> {
  final String content;

  TextDisplayComponentBuilder({required this.content, super.id}) : super(type: MessageComponentType.textDisplay);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'content': content,
      };
}

class UnfurledMediaItemBuilder extends CreateBuilder<UnfurledMediaItem> {
  Uri url;

  UnfurledMediaItemBuilder({required this.url});

  @override
  Map<String, Object?> build() => {'url': url.toString()};
}

class ThumbnailComponentBuilder extends MessageComponentBuilder<ThumbnailComponent> {
  UnfurledMediaItemBuilder media;

  String? description;

  bool? isSpoiler;

  ThumbnailComponentBuilder({required this.media, this.description, this.isSpoiler, super.id}) : super(type: MessageComponentType.thumbnail);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'media': media.build(),
        if (description != null) 'description': description,
        if (isSpoiler != null) 'spoiler': isSpoiler,
      };
}

class MediaGalleryItemBuilder extends CreateBuilder<MediaGalleryItem> {
  UnfurledMediaItemBuilder media;

  String? description;

  bool? isSpoiler;

  MediaGalleryItemBuilder({required this.media, this.description, this.isSpoiler});

  @override
  Map<String, Object?> build() => {
        'media': media.build(),
        if (description != null) 'description': description,
        if (isSpoiler != null) 'spoiler': isSpoiler,
      };
}

class MediaGalleryComponentBuilder extends MessageComponentBuilder<MediaGalleryComponent> {
  List<MediaGalleryItemBuilder> items;

  MediaGalleryComponentBuilder({required this.items, super.id}) : super(type: MessageComponentType.mediaGallery);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'items': items.map((e) => e.build()).toList(),
      };
}

class SeparatorComponentBuilder extends MessageComponentBuilder<SeparatorComponent> {
  bool? isDivider;

  SeparatorSpacingSize? spacing;

  SeparatorComponentBuilder({this.isDivider, this.spacing, super.id}) : super(type: MessageComponentType.separator);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (isDivider != null) 'divider': isDivider,
        if (spacing != null) 'spacing': spacing!.value,
      };
}

class FileComponentBuilder extends MessageComponentBuilder<FileComponent> {
  UnfurledMediaItemBuilder file;

  bool? isSpoiler;

  FileComponentBuilder({required this.file, this.isSpoiler, super.id}) : super(type: MessageComponentType.file);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'file': file.build(),
        if (isSpoiler != null) 'spoiler': isSpoiler,
      };
}

class ContainerComponentBuilder extends MessageComponentBuilder<ContainerComponent> {
  DiscordColor? accentColor;

  bool? isSpoiler;

  List<MessageComponentBuilder> components;

  ContainerComponentBuilder({required this.components, this.accentColor, this.isSpoiler, super.id}) : super(type: MessageComponentType.container);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (accentColor != null) 'accent_color': accentColor!.value,
        if (isSpoiler != null) 'spoiler': isSpoiler,
        'components': components.map((e) => e.build()).toList(),
      };
}

class LabelComponentBuilder extends MessageComponentBuilder<SubmittedLabelComponent> {
  String label;

  String? description;

  MessageComponentBuilder component;

  LabelComponentBuilder({
    required this.label,
    this.description,
    required this.component,
  }) : super(type: MessageComponentType.label);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'label': label,
        if (description != null) 'description': description,
        'component': component.build(),
      };
}

class FileUploadComponentBuilder
    extends MessageComponentBuilder<FileUploadComponent> {
  String customId;

  int? minValues;

  int? maxValues;

  bool? isRequired;

  FileUploadComponentBuilder(
      {required this.customId, this.minValues, this.maxValues, this.isRequired})
      : super(type: MessageComponentType.fileUpload);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        'custom_id': customId,
        if (minValues != null) 'min_values': minValues,
        if (maxValues != null) 'max_values': maxValues,
        if (isRequired != null) 'required': isRequired,
      };
}
