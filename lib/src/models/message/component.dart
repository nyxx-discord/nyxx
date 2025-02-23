import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// The type of a [MessageComponent].
final class MessageComponentType extends EnumLike<int, MessageComponentType> {
  static const actionRow = MessageComponentType(1);
  static const button = MessageComponentType(2);
  static const stringSelect = MessageComponentType(3);
  static const textInput = MessageComponentType(4);
  static const userSelect = MessageComponentType(5);
  static const roleSelect = MessageComponentType(6);
  static const mentionableSelect = MessageComponentType(7);
  static const channelSelect = MessageComponentType(8);
  static const section = MessageComponentType(9);
  static const textDisplay = MessageComponentType(10);
  static const thumbnail = MessageComponentType(11);
  static const mediaGallery = MessageComponentType(12);
  static const file = MessageComponentType(13);
  static const separator = MessageComponentType(14);
  static const container = MessageComponentType(17);

  /// @nodoc
  const MessageComponentType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  MessageComponentType.parse(int value) : this(value);
}

class UnfurledMediaItem with ToStringHelper {
  /// The URL of this media item.
  final Uri url;

  /// A proxied URL of this media item.
  final Uri? proxiedUrl;

  /// The height of this media item if it is an image.
  final int? height;

  /// The width of this media item if it is an image.
  final int? width;

  /// @nodoc
  UnfurledMediaItem({
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
  });
}

/// A component in a [Message].
abstract class MessageComponent with ToStringHelper {
  /// The type of this component.
  MessageComponentType get type;

  final int id;

  MessageComponent({required this.id});
}

/// A [MessageComponent] that contains multiple child [MessageComponent]s.
class ActionRowComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.actionRow;

  /// The children of this [ActionRowComponent].
  final List<MessageComponent> components;

  /// Create a new [ActionRowComponent].
  /// @nodoc
  ActionRowComponent({required this.components, required super.id});
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

  /// The purchasable SKU ID, if this button has [ButtonStyle.premium] style.
  final Snowflake? skuId;

  /// The URL this button redirects to, if this button is a URL button.
  final Uri? url;

  /// Whether this button is disabled.
  final bool? isDisabled;

  /// Create a new [ButtonComponent].
  /// @nodoc
  ButtonComponent({
    required this.style,
    required this.label,
    required this.emoji,
    required this.customId,
    required this.skuId,
    required this.url,
    required this.isDisabled,
    required super.id,
  });
}

/// The style of a [ButtonComponent].
final class ButtonStyle extends EnumLike<int, ButtonStyle> {
  static const primary = ButtonStyle(1);
  static const secondary = ButtonStyle(2);
  static const success = ButtonStyle(3);
  static const danger = ButtonStyle(4);
  static const link = ButtonStyle(5);
  static const premium = ButtonStyle(6);

  /// @nodoc
  const ButtonStyle(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  ButtonStyle.parse(int value) : this(value);
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
  /// @nodoc
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
    required super.id,
  });
}

/// The type of a [SelectMenuDefaultValue].
final class SelectMenuDefaultValueType extends EnumLike<String, SelectMenuDefaultValueType> {
  static const user = SelectMenuDefaultValueType('user');
  static const role = SelectMenuDefaultValueType('role');
  static const channel = SelectMenuDefaultValueType('channel');

  /// @nodoc
  const SelectMenuDefaultValueType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  SelectMenuDefaultValueType.parse(String value) : this(value);
}

/// A default value in a [SelectMenuComponent].
class SelectMenuDefaultValue {
  /// The ID of this entity.
  final Snowflake id;

  /// The type of this entity.
  final SelectMenuDefaultValueType type;

  /// Create a new [SelectMenuDefaultValue].
  /// @nodoc
  SelectMenuDefaultValue({required this.id, required this.type});
}

/// An option in a [SelectMenuComponent].
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
  /// @nodoc
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
  /// @nodoc
  TextInputComponent({
    required this.customId,
    required this.style,
    required this.label,
    required this.minLength,
    required this.maxLength,
    required this.isRequired,
    required this.value,
    required this.placeholder,
    required super.id,
  });
}

/// The type of a [TextInputComponent].
final class TextInputStyle extends EnumLike<int, TextInputStyle> {
  static const short = TextInputStyle(1);
  static const paragraph = TextInputStyle(2);

  /// @nodoc
  const TextInputStyle(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  TextInputStyle.parse(int value) : this(value);
}

class SectionComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.section;

  final List<TextDisplayComponent> components;

  final MessageComponent accessory;

  SectionComponent({required super.id, required this.components, required this.accessory});
}

class TextDisplayComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.textDisplay;

  final String content;

  TextDisplayComponent({required super.id, required this.content});
}

class ThumbnailComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.thumbnail;

  final UnfurledMediaItem media;

  final String? description;

  final bool? isSpoiler;

  ThumbnailComponent({required super.id, required this.media, required this.description, required this.isSpoiler});
}

class MediaGalleryItem with ToStringHelper {
  final UnfurledMediaItem media;

  final String? description;

  final bool? isSpoiler;

  MediaGalleryItem({required this.media, required this.description, required this.isSpoiler});
}

class MediaGalleryComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.mediaGallery;

  final List<MediaGalleryItem> items;

  MediaGalleryComponent({required super.id, required this.items});
}

final class SeparatorSpacingSize extends EnumLike<int, SeparatorSpacingSize> {
  static const small = SeparatorSpacingSize(1);
  static const large = SeparatorSpacingSize(2);

  const SeparatorSpacingSize(super.value);
}

class SeparatorComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.separator;

  final bool? isDivider;

  final SeparatorSpacingSize? spacing;

  SeparatorComponent({required super.id, required this.isDivider, required this.spacing});
}

class FileComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.file;

  final UnfurledMediaItem file;

  final bool? isSpoiler;

  FileComponent({required super.id, required this.file, required this.isSpoiler});
}

class ContainerComponent extends MessageComponent {
  @override
  MessageComponentType get type => MessageComponentType.container;

  final DiscordColor? accentColor;

  final bool? isSpoiler;

  final List<MessageComponent> components;

  ContainerComponent({required super.id, required this.accentColor, required this.isSpoiler, required this.components});
}
