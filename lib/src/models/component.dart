/// @docImport 'package:nyxx/nyxx.dart';
library;

import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// The type of a [Component].
final class ComponentType extends EnumLike<int, ComponentType> {
  static const actionRow = ComponentType(1);
  static const button = ComponentType(2);
  static const stringSelect = ComponentType(3);
  static const textInput = ComponentType(4);
  static const userSelect = ComponentType(5);
  static const roleSelect = ComponentType(6);
  static const mentionableSelect = ComponentType(7);
  static const channelSelect = ComponentType(8);
  static const section = ComponentType(9);
  static const textDisplay = ComponentType(10);
  static const thumbnail = ComponentType(11);
  static const mediaGallery = ComponentType(12);
  static const file = ComponentType(13);
  static const separator = ComponentType(14);
  static const container = ComponentType(17);
  static const label = ComponentType(18);
  static const fileUpload = ComponentType(19);
  static const radioGroup = ComponentType(21);
  static const checkboxGroup = ComponentType(22);
  static const checkbox = ComponentType(23);

  /// @nodoc
  const ComponentType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  ComponentType.parse(int value) : this(value);
}

/// @nodoc
@Deprecated('Use ComponentType instead')
typedef MessageComponentType = ComponentType;

class UnfurledMediaItem with ToStringHelper implements CdnAsset {
  /// The manager for this [UnfurledMediaItem].
  final MessageManager manager;

  @override
  Nyxx get client => manager.client;

  /// The URL of this media item.
  @override
  final Uri url;

  /// A proxied URL of this media item.
  final Uri? proxiedUrl;

  /// The height of this media item if it is an image.
  final int? height;

  /// The width of this media item if it is an image.
  final int? width;

  /// @nodoc
  UnfurledMediaItem({
    required this.manager,
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
  });

  @override
  HttpRoute get base => throw UnsupportedError('Cannot get the base URL for a media item');

  @override
  CdnFormat get defaultFormat => throw UnsupportedError('Cannot get the default format for a media item');

  @override
  String get hash => throw UnsupportedError('Cannot get the hash for a media item');

  @override
  bool get isAnimated => false;

  @override
  Future<Uint8List> fetch({CdnFormat? format, int? size}) async {
    if (format != null || size != null) {
      throw UnsupportedError('Cannot specify attachment format or size');
    }

    final response = await client.httpHandler.httpClient.get(url);
    return response.bodyBytes;
  }

  @override
  Stream<List<int>> fetchStreamed({CdnFormat? format, int? size}) async* {
    if (format != null || size != null) {
      throw UnsupportedError('Cannot specify attachment format or size');
    }

    final response = await client.httpHandler.httpClient.send(Request('GET', url));
    yield* response.stream;
  }
}

/// A component in a [Message].
///
/// Components sent in modals can never be fetched by the client. Instead, see
/// [SubmittedComponent] for obtaining the values submitted by the user.
abstract class Component with ToStringHelper {
  /// The type of this component.
  ComponentType get type;

  /// An identifier for this component.
  final int id;

  /// @nodoc
  Component({required this.id});
}

/// @nodoc
@Deprecated('Use Component instead')
typedef MessageComponent = Component;

/// A [Component] that contains multiple child [Component]s.
class ActionRowComponent extends Component {
  @override
  ComponentType get type => ComponentType.actionRow;

  /// The children of this [ActionRowComponent].
  final List<Component> components;

  /// Create a new [ActionRowComponent].
  /// @nodoc
  ActionRowComponent({required this.components, required super.id});
}

/// A clickable button.
class ButtonComponent extends Component {
  @override
  ComponentType get type => ComponentType.button;

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
class SelectMenuComponent extends Component {
  @override
  final ComponentType type;

  /// This component's custom ID.
  final String customId;

  /// The options in this menu.
  ///
  /// Will be `null` if this menu is not a [ComponentType.stringSelect] menu.
  final List<SelectMenuOption>? options;

  /// The channel types displayed in this select menu.
  ///
  /// Will be `null` if this menu is not a [ComponentType.channelSelect] menu.
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

  /// Whether this component is required when in a modal.
  ///
  /// Only applicable to select menus with type [ComponentType.stringSelect]
  final bool? isRequired;

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
    required this.isRequired,
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
@Deprecated('Use SubmittedTextInputComponent instead. The fields on this class are never populated.')
class TextInputComponent extends Component implements SubmittedTextInputComponent {
  @override
  ComponentType get type => ComponentType.textInput;

  /// This component's custom ID.
  @override
  final String customId;

  /// The style of this [TextInputComponent].
  @Deprecated('This field is never populated.')
  final TextInputStyle? style;

  /// This component's label.
  @Deprecated('This field is never populated.')
  final String? label;

  /// The minimum number of characters the user must input.
  @Deprecated('This field is never populated.')
  final int? minLength;

  /// The maximum number of characters the user can input.
  @Deprecated('This field is never populated.')
  final int? maxLength;

  /// Whether this component requires input.
  @Deprecated('This field is never populated.')
  final bool? isRequired;

  /// The text contained in this component.
  @Deprecated('This field is never populated.')
  @override
  final String? value;

  /// Placeholder text shown when this component is empty.
  @Deprecated('This field is never populated.')
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

/// The type of a [SubmittedTextInputComponent].
final class TextInputStyle extends EnumLike<int, TextInputStyle> {
  static const short = TextInputStyle(1);
  static const paragraph = TextInputStyle(2);

  /// @nodoc
  const TextInputStyle(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  TextInputStyle.parse(int value) : this(value);
}

/// An unknown component.
class UnknownComponent extends Component implements SubmittedComponent {
  @override
  final ComponentType type;

  /// @nodoc
  UnknownComponent({required this.type, required super.id});
}

/// A section in a message, with small accessory component.
class SectionComponent extends Component {
  @override
  ComponentType get type => ComponentType.section;

  /// The components in this section.
  final List<TextDisplayComponent> components;

  /// A small component displayed at the top of the section.
  final Component accessory;

  /// @nodoc
  SectionComponent({required super.id, required this.components, required this.accessory});
}

/// A component that displays text.
class TextDisplayComponent extends Component {
  @override
  ComponentType get type => ComponentType.textDisplay;

  /// The content of this section.
  final String content;

  /// @nodoc
  TextDisplayComponent({required super.id, required this.content});
}

/// A component that shows a small image.
class ThumbnailComponent extends Component {
  @override
  ComponentType get type => ComponentType.thumbnail;

  /// The image that is shown.
  final UnfurledMediaItem media;

  /// A description of the image.
  final String? description;

  /// Whether the image should be spoilered.
  final bool? isSpoiler;

  /// @nodoc
  ThumbnailComponent({required super.id, required this.media, required this.description, required this.isSpoiler});
}

/// An item in a [MediaGalleryComponent].
class MediaGalleryItem with ToStringHelper {
  /// The item to display.
  final UnfurledMediaItem media;

  /// A description of the item.
  final String? description;

  /// Whether the item should be spoilered.
  final bool? isSpoiler;

  /// @nodoc
  MediaGalleryItem({required this.media, required this.description, required this.isSpoiler});
}

/// A component that displays several child media items.
class MediaGalleryComponent extends Component {
  @override
  ComponentType get type => ComponentType.mediaGallery;

  /// The items to display.
  final List<MediaGalleryItem> items;

  /// @nodoc
  MediaGalleryComponent({required super.id, required this.items});
}

/// The size of the spacing introduced by a [SeparatorComponent].
final class SeparatorSpacingSize extends EnumLike<int, SeparatorSpacingSize> {
  static const small = SeparatorSpacingSize(1);
  static const large = SeparatorSpacingSize(2);

  /// @nodoc
  const SeparatorSpacingSize(super.value);
}

/// A component that introduces space between two other components.
class SeparatorComponent extends Component {
  @override
  ComponentType get type => ComponentType.separator;

  /// Whether this component should render a divider line.
  final bool? isDivider;

  /// The size of the space introduced by this component.
  final SeparatorSpacingSize? spacing;

  /// @nodoc
  SeparatorComponent({required super.id, required this.isDivider, required this.spacing});
}

/// A component that displays a downloadable file.
class FileComponent extends Component {
  @override
  ComponentType get type => ComponentType.file;

  /// The file that can be downloaded.
  final UnfurledMediaItem file;

  /// Whether the file should be spoilered.
  final bool? isSpoiler;

  /// @nodoc
  FileComponent({required super.id, required this.file, required this.isSpoiler});
}

/// A component that contains several other components.
class ContainerComponent extends Component {
  @override
  ComponentType get type => ComponentType.container;

  /// The accent color for this container.
  final DiscordColor? accentColor;

  /// Whether this container should be spoilered.
  final bool? isSpoiler;

  /// The components in this container.
  final List<Component> components;

  /// @nodoc
  ContainerComponent({required super.id, required this.accentColor, required this.isSpoiler, required this.components});
}

class FileUploadComponent extends Component {
  @override
  ComponentType get type => ComponentType.fileUpload;

  /// The custom id for this component
  final String customId;

  /// The minimum number of files the user must upload. (default 1, min 0)
  final int? minValues;

  /// The maximum number of files the user can upload. (default 1, max 10)
  final int? maxValues;

  /// Whether this component is required when in a modal.
  final bool? isRequired;

  /// @nodoc
  FileUploadComponent({required super.id, required this.customId, required this.minValues, required this.maxValues, required this.isRequired});
}

/// A component received as part of an [Interaction].
abstract class SubmittedComponent extends Component {
  /// @nodoc
  SubmittedComponent({required super.id});
}

/// An [ActionRowComponent] received in an [Interaction].
class SubmittedActionRowComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.actionRow;

  /// The components submitted in this action row.
  final List<SubmittedComponent> components;

  /// @nodoc
  SubmittedActionRowComponent({required this.components, required super.id});
}

/// A text input received in an [Interaction].
class SubmittedTextInputComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.textInput;

  /// The custom ID of this text input.
  final String customId;

  /// The value submitted by the user, or `null` if no value was submitted.
  final String? value;

  /// @nodoc
  SubmittedTextInputComponent({required super.id, required this.customId, required this.value});
}

/// A label received in an [Interaction].
class SubmittedLabelComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.label;

  /// The component in this label that was submitted.
  final SubmittedComponent component;

  /// @nodoc
  SubmittedLabelComponent({required super.id, required this.component});
}

/// A [SelectMenuComponent] received in an [Interaction].
class SubmittedSelectMenuComponent extends SubmittedComponent {
  final MessageManager manager;
  // For the [roles] getter.
  final Snowflake? _guildId;

  @override
  final ComponentType type;

  /// The custom ID of this select menu.
  final String customId;

  /// The values selected by the user.
  final List<String> values;

  /// @nodoc
  SubmittedSelectMenuComponent({
    required this.manager,
    Snowflake? guildId,
    required this.type,
    required super.id,
    required this.customId,
    required this.values,
  }) : _guildId = guildId;

  /// The selected users.
  ///
  /// Will be `null` if `type` is not [ComponentType.userSelect].
  List<PartialUser>? get users => type != ComponentType.userSelect
      ? null
      : [
          for (final id in values) manager.client.users[Snowflake.parse(id)],
        ];

  /// The selected members.
  ///
  /// Will be `null` if `type` is not [ComponentType.userSelect].
  List<PartialMember>? get members => type != ComponentType.userSelect
      ? null
      : [
          for (final id in values) manager.client.guilds[_guildId ?? Snowflake.zero].members[Snowflake.parse(id)],
        ];

  /// The selected roles.
  ///
  /// Will be `null` if `type` is not [ComponentType.roleSelect].
  List<PartialRole>? get roles => type != ComponentType.roleSelect
      ? null
      : [
          for (final id in values) manager.client.guilds[_guildId ?? Snowflake.zero].roles[Snowflake.parse(id)],
        ];

  /// The selected channels.
  ///
  /// Will be `null` if `type` is not [ComponentType.channelSelect].
  List<PartialChannel>? get channels => type != ComponentType.channelSelect
      ? null
      : [
          for (final id in values) manager.client.channels[Snowflake.parse(id)],
        ];
}

/// A [TextDisplayComponent] received in an [Interaction].
class SubmittedTextDisplayComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.textDisplay;

  /// @nodoc
  SubmittedTextDisplayComponent({required super.id});
}

class SubmittedFileUploadComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.fileUpload;

  /// The custom id for this component
  final String customId;

  /// IDs of the uploaded files in the resolved data
  final List<Snowflake> values;

  /// @nodoc
  SubmittedFileUploadComponent({required super.id, required this.customId, required this.values});
}

class SubmittedRadioGroupComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.radioGroup;

  /// The custom id for this component.
  final String customId;

  /// The value of the selected option.
  final String value;

  /// @nodoc
  SubmittedRadioGroupComponent({required super.id, required this.customId, required this.value});
}

class SubmittedCheckboxGroupComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.checkboxGroup;

  /// The custom id for this component.
  final String customId;

  /// The selected values.
  final List<String> values;

  /// @nodoc
  SubmittedCheckboxGroupComponent({required super.id, required this.customId, required this.values});
}

class SubmittedCheckboxComponent extends SubmittedComponent {
  @override
  ComponentType get type => ComponentType.checkbox;

  /// The custom id for this component.
  final String customId;

  /// Whether the checkbox is selected.
  final bool value;

  /// @nodoc
  SubmittedCheckboxComponent({required super.id, required this.customId, required this.value});
}
