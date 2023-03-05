import 'dart:convert';

import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/core/message/components/component_style.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';

/// Type of interaction component
class ComponentType extends IEnum<int> {
  /// Row where other components can be placed
  static const ComponentType row = ComponentType._create(1);

  /// Button object.
  static const ComponentType button = ComponentType._create(2);

  /// Select menu for picking from defined text options.
  static const ComponentType multiSelect = ComponentType._create(3);

  /// Text input object.
  static const ComponentType text = ComponentType._create(4);

  /// Select menu for users.
  static const ComponentType userMultiSelect = ComponentType._create(5);

  /// Select menu for roles.
  static const ComponentType roleMultiSelect = ComponentType._create(6);

  /// Select menu for mentionables (users and roles).
  static const ComponentType mentionableMultiSelect = ComponentType._create(7);

  /// Select menu for channels.
  static const ComponentType channelMultiSelect = ComponentType._create(8);

  const ComponentType._create(int value) : super(value);

  /// Create [ComponentType] from [value]
  ComponentType.from(int value) : super(value);
}

abstract class IMessageComponentEmoji {
  /// Reference to [INyxx].
  INyxx get client;

  /// Name of the emoji if unicode emoji
  String? get name;

  /// Id of the emoji if guid emoji
  String? get id;

  /// True if emoji is animated
  bool get animated;

  /// Returns emoji from button as emoji button native for nyxx
  IEmoji get parsedEmoji;
}

/// Spacial emoji object for [MessageComponent]
class MessageComponentEmoji implements IMessageComponentEmoji {
  @override
  final INyxx client;

  /// Name of the emoji if unicode emoji
  @override
  late final String? name;

  /// Id of the emoji if guid emoji
  @override
  late final String? id;

  /// True if emoji is animated
  @override
  late final bool animated;

  /// Returns emoji from button as emoji button native for nyxx
  @override
  IEmoji get parsedEmoji {
    if (name != null) {
      return UnicodeEmoji(name!);
    }

    if (id != null) {
      return IBaseGuildEmoji.fromId(Snowflake(id), client);
    }

    throw ArgumentError("Tried to parse emojis from invalid payload");
  }

  /// Creates an instance of [MessageComponentEmoji]
  MessageComponentEmoji(RawApiMap raw, this.client) {
    name = raw["name"] as String?;
    id = raw["id"] as String?;
    animated = raw["animated"] as bool? ?? false;
  }
}

abstract class IMessageComponent {
  /// The [ComponentType]
  ComponentType get type;

  /// The custom id of this component, set by the user, if there isn't one, an empty string is returned.
  // TODO: Add nullable string in next major release.
  String get customId;
}

/// Generic container for components that can be attached to message
abstract class MessageComponent implements IMessageComponent {
  /// Type of component.
  @override
  ComponentType get type;

  @override
  late final String customId;

  MessageComponent(RawApiMap raw) {
    customId = raw['custom_id'] as String? ?? '';
  }

  factory MessageComponent.deserialize(RawApiMap raw, INyxx client) {
    final type = raw["type"] as int;

    switch (type) {
      case 2:
        return MessageButton.deserialize(raw, client);
      case 3:
        return MessageMultiselect(raw, client);
      case 4:
        return MessageTextInput(raw);
      case 5:
        return MessageUserMultiSelect(raw);
      case 6:
        return MessageRoleMultiSelect(raw);
      case 7:
        return MessageMentionableMultiSelect(raw);
      case 8:
        return MessageChannelMultiSelect(raw);
    }

    throw ArgumentError("Unknown interaction type: [$type]: ${jsonEncode(raw)}");
  }
}

abstract class MultiSelectAbstract extends MessageComponent {
  /// Custom placeholder when no option selected
  late final String? placeholder;

  /// Min value of selected options
  late final int minValues;

  /// Max value of selected options
  late final int maxValues;

  /// Whether this multiselect is disabled.
  late final bool isDisabled;

  MultiSelectAbstract(RawApiMap raw) : super(raw) {
    placeholder = raw['placeholder'] as String?;
    minValues = raw['min_values'] as int? ?? 1;
    maxValues = raw['max_values'] as int? ?? 1;
    isDisabled = raw['disabled'] as bool? ?? false;
  }
}

/// Text input component
abstract class IMessageTextInput implements IMessageComponent {
  /// Value of component
  String get value;
}

class MessageTextInput extends MessageComponent implements IMessageTextInput {
  @override
  ComponentType get type => ComponentType.text;

  @override
  late final String value;

  MessageTextInput(RawApiMap raw) : super(raw) {
    value = raw['value'] as String;
  }
}

abstract class IMessageMultiselectOption {
  /// Reference to [INyxx].
  INyxx get client;

  /// Option label
  String get label;

  /// Value of option
  String get value;

  /// Additional description for option
  String? get description;

  /// Additional emoji that is displayed before label
  IMessageComponentEmoji? get emoji;

  /// True of option will be preselected in UI
  bool get isDefault;
}

class MessageMultiselectOption implements IMessageMultiselectOption {
  @override
  final INyxx client;

  /// Option label
  @override
  late final String label;

  /// Value of option
  @override
  late final String value;

  /// Additional description for option
  @override
  late final String? description;

  /// Additional emoji that is displayed before label
  @override
  late final IMessageComponentEmoji? emoji;

  /// True of option will be preselected in UI
  @override
  late final bool isDefault;

  /// Creates an instance of [MessageMultiselectOption]
  MessageMultiselectOption(RawApiMap raw, this.client) {
    label = raw["label"] as String;
    value = raw["value"] as String;

    description = raw["description"] as String?;
    if (raw["emoji"] != null) {
      emoji = MessageComponentEmoji(raw["emoji"] as Map<String, dynamic>, client);
    } else {
      emoji = null;
    }
    isDefault = raw["default"] as bool? ?? false;
  }
}

abstract class IMessageMultiselect implements MultiSelectAbstract {
  /// Reference to [INyxx].
  INyxx get client;

  /// Possible options of multiselect.
  Iterable<IMessageMultiselectOption> get options;
}

class MessageMultiselect extends MultiSelectAbstract implements IMessageMultiselect {
  @override
  final INyxx client;

  @override
  ComponentType get type => ComponentType.multiSelect;

  /// Possible options of multiselect
  @override
  late final Iterable<IMessageMultiselectOption> options;

  /// Creates an instance of [MessageMultiselect]
  MessageMultiselect(RawApiMap raw, this.client) : super(raw) {
    options = [for (final rawOption in raw["options"] as RawApiList) MessageMultiselectOption(rawOption as Map<String, dynamic>, client)];
  }
}

abstract class IMessageUserMultiSelect implements MultiSelectAbstract {}

class MessageUserMultiSelect extends MultiSelectAbstract implements IMessageUserMultiSelect {
  @override
  ComponentType get type => ComponentType.userMultiSelect;

  MessageUserMultiSelect(super.raw);
}

abstract class IMessageRoleMultiSelect implements MultiSelectAbstract {}

class MessageRoleMultiSelect extends MultiSelectAbstract implements IMessageRoleMultiSelect {
  @override
  ComponentType get type => ComponentType.roleMultiSelect;

  MessageRoleMultiSelect(super.raw);
}

abstract class IMessageMentionableMultiSelect implements MultiSelectAbstract {}

class MessageMentionableMultiSelect extends MultiSelectAbstract implements IMessageMentionableMultiSelect {
  @override
  ComponentType get type => ComponentType.mentionableMultiSelect;

  MessageMentionableMultiSelect(super.raw);
}

abstract class IMessageChannelMultiSelect implements MultiSelectAbstract {
  /// The channel types of this select.
  Iterable<ChannelType>? get channelTypes;
}

class MessageChannelMultiSelect extends MultiSelectAbstract implements IMessageChannelMultiSelect {
  @override
  ComponentType get type => ComponentType.channelMultiSelect;

  @override
  late final Iterable<ChannelType>? channelTypes;

  MessageChannelMultiSelect(RawApiMap raw) : super(raw) {
    channelTypes = raw['channel_types'] != null ? (raw['channel_types'] as List).cast<int>().map(ChannelType.from) : null;
  }
}

abstract class IMessageButton implements IMessageComponent {
  /// What the button says (max 80 characters)
  String? get label;

  /// Component style, appearance
  ButtonStyle get style;

  /// Additional emoji that will be displayed before label
  IMessageComponentEmoji? get emoji;

  /// True if button is disabled
  bool get disabled;
}

/// Button component for Message
class MessageButton extends MessageComponent implements IMessageButton {
  @override
  ComponentType get type => ComponentType.button;

  /// What the button says (max 80 characters)
  @override
  late final String? label;

  /// Component style, appearance
  @override
  late final ButtonStyle style;

  /// Additional emoji that will be displayed before label
  @override
  late final IMessageComponentEmoji? emoji;

  /// True if button is disabled
  @override
  late final bool disabled;

  factory MessageButton.deserialize(RawApiMap raw, INyxx client) {
    if (raw["style"] == ButtonStyle.link.value) {
      return LinkMessageButton(raw, client);
    }

    return MessageButton(raw, client);
  }

  /// Creates an instance of [MessageButton]
  MessageButton(RawApiMap raw, INyxx client) : super(raw) {
    label = raw["label"] as String?;
    style = ButtonStyle.from(raw["style"] as int);

    if (raw["emoji"] != null) {
      emoji = MessageComponentEmoji(raw["emoji"] as RawApiMap, client);
    } else {
      emoji = null;
    }

    disabled = raw["disabled"] as bool? ?? false;
  }
}

abstract class ILinkMessageButton implements IMessageButton {
  /// Url where button points
  String get url;

  /// buttons url as [Uri]
  Uri get uri;
}

/// Button with a link that user will be redirected after clicking
class LinkMessageButton extends MessageButton implements ILinkMessageButton {
  /// Url where button points
  @override
  late final String url;

  /// buttons url as [Uri]
  @override
  Uri get uri => Uri.parse(url);

  /// Creates an instance of [LinkMessageButton]
  LinkMessageButton(RawApiMap raw, INyxx client) : super(raw, client) {
    url = raw["url"] as String;
  }
}
