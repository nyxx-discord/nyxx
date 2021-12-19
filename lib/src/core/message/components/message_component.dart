import 'dart:convert';

import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/core/message/components/component_style.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';

/// Type of interaction component
class ComponentType extends IEnum<int> {
  /// Row where other components can be placed
  static const ComponentType row = ComponentType._create(1);

  static const ComponentType button = ComponentType._create(2);
  static const ComponentType select = ComponentType._create(3);

  const ComponentType._create(int value) : super(value);

  /// Create [ComponentType] from [value]
  ComponentType.from(int value) : super(value);
}

abstract class IMessageComponentEmoji {
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
      return IBaseGuildEmoji.fromId(Snowflake(id));
    }

    throw ArgumentError("Tried to parse emojis from invalid payload");
  }

  /// Creates an instance of [MessageComponentEmoji]
  MessageComponentEmoji(RawApiMap raw) {
    name = raw["name"] as String?;
    id = raw["id"] as String?;
    animated = raw["animated"] as bool? ?? false;
  }
}

abstract class IMessageComponent {
  /// The [ComponentType]
  ComponentType get type;
}

/// Generic container for components that can be attached to message
abstract class MessageComponent implements IMessageComponent {
  /// [ComponentType]
  @override
  ComponentType get type;

  /// Empty constructor
  MessageComponent();

  factory MessageComponent.deserialize(Map<String, dynamic> raw) {
    final type = raw["type"] as int;

    switch (type) {
      case 2:
        return MessageButton.deserialize(raw);
      case 3:
        return MessageMultiselect(raw);
    }

    throw ArgumentError("Unknown interaction type: [$type]: ${jsonEncode(raw)}");
  }
}

abstract class IMessageMultiselectOption {
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
  MessageMultiselectOption(Map<String, dynamic> raw) {
    label = raw["label"] as String;
    value = raw["value"] as String;

    description = raw["description"] as String?;
    if (raw["emoji"] != null) {
      emoji = MessageComponentEmoji(raw["emoji"] as Map<String, dynamic>);
    } else {
      emoji = null;
    }
    isDefault = raw["default"] as bool? ?? false;
  }
}

abstract class IMessageMultiselect implements IMessageComponent {
  /// A dev-defined unique string sent on click (max 100 characters)
  String get customId;

  /// Custom placeholder when no option selected
  String? get placeholder;

  /// Min value of selected options
  int get minValues;

  /// Max value of selected options
  int get maxValues;

  /// Possible options of multiselect
  Iterable<IMessageMultiselectOption> get options;
}

class MessageMultiselect extends MessageComponent implements IMessageMultiselect {
  @override
  ComponentType get type => ComponentType.select;

  /// A dev-defined unique string sent on click (max 100 characters)
  @override
  late final String customId;

  /// Custom placeholder when no option selected
  @override
  late final String? placeholder;

  /// Min value of selected options
  @override
  late final int minValues;

  /// Max value of selected options
  @override
  late final int maxValues;

  /// Possible options of multiselect
  @override
  late final Iterable<IMessageMultiselectOption> options;

  /// Creates an instance of [MessageMultiselect]
  MessageMultiselect(Map<String, dynamic> raw) : super() {
    customId = raw["custom_id"] as String;
    placeholder = raw["placeholder"] as String?;
    minValues = raw["min_values"] as int? ?? 1;
    maxValues = raw["max_values"] as int? ?? 1;
    options = [for (final rawOption in raw["options"]) MessageMultiselectOption(rawOption as Map<String, dynamic>)];
  }
}

abstract class IMessageButton implements IMessageComponent {
  /// What the button says (max 80 characters)
  String? get label;

  /// Component style, appearance
  ComponentStyle get style;

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
  late final ComponentStyle style;

  /// Additional emoji that will be displayed before label
  @override
  late final IMessageComponentEmoji? emoji;

  /// True if button is disabled
  @override
  late final bool disabled;

  factory MessageButton.deserialize(RawApiMap raw) {
    if (raw["style"] == ComponentStyle.link.value) {
      return LinkMessageButton(raw);
    }

    return MessageButton(raw);
  }

  /// Creates an instance of [MessageButton]
  MessageButton(Map<String, dynamic> raw) : super() {
    label = raw["label"] as String?;
    style = ComponentStyle.from(raw["style"] as int);

    if (raw["emoji"] != null) {
      emoji = MessageComponentEmoji(raw["emoji"] as RawApiMap);
    } else {
      emoji = null;
    }

    disabled = raw["disabled"] as bool? ?? false;
  }
}

abstract class ICustomMessageButton implements IMessageButton {
  ///  a dev-defined unique string sent on click (max 100 characters)
  String get customId;
}

/// Represents button that has attached metadata and will generate interaction event
class CustomMessageButton extends MessageButton implements ICustomMessageButton {
  ///  a dev-defined unique string sent on click (max 100 characters)
  @override
  late final String customId;

  /// Creates an instance of [CustomMessageButton]
  CustomMessageButton(RawApiMap raw) : super(raw) {
    customId = raw["custom_id"] as String;
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
  LinkMessageButton(RawApiMap raw) : super(raw) {
    url = raw["url"] as String;
  }
}
