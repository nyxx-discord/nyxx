part of nyxx;

/// Type of interaction component
class ComponentType extends IEnum<int> {
  /// Row where other components can be placed
  static const ComponentType row = const ComponentType._create(1);

  static const ComponentType button = const ComponentType._create(2);
  static const ComponentType select = const ComponentType._create(3);

  const ComponentType._create(int value) : super(value);
  /// Create [ComponentType] from [value]
  ComponentType.from(int value) : super(value);
}

/// Spacial emoji object for [IMessageComponent]
class MessageComponentEmoji {
  /// Name of the emoji if unicode emoji
  late final String? name;

  /// Id of the emoji if guid emoji
  late final String? id;

  /// True if emoji is animated
  late final bool animated;

  // TODO: handle animated in partial emojis
  /// Returns emoji from button as emoji button native for nyxx
  IEmoji get parsedEmoji {
    if (this.name != null) {
      return UnicodeEmoji(this.name!);
    }

    if (this.id != null) {
      return IGuildEmoji.fromId(this.id!);
    }

    throw new ArgumentError("Tried to parse emojis from invalid payload");
  }

  MessageComponentEmoji._new(RawApiMap raw) {
    this.name = raw["name"] as String?;
    this.id = raw["id"] as String?;
    this.animated = raw["animated"] as bool? ?? false;
  }
}

/// Generic container for components that can be attached to message
abstract class IMessageComponent {
  /// [ComponentType]
  ComponentType get type;

  /// Empty constructor
  IMessageComponent._new();

  factory IMessageComponent._deserialize(Map<String, dynamic> raw) {
    final type = raw["type"] as int;

    switch(type) {
      case 2:
        return IMessageButton._deserialize(raw);
      case 3:
        return MessageMultiselect._new(raw);
    }

    throw new ArgumentError("Unknown interaction type: [$type]: ${jsonEncode(raw)}");
  }
}

class MessageMultiselectOption {
  /// Option label
  late final String label;

  /// Value of option
  late final String value;

  /// Additional description for option
  late final String? description;

  /// Additional emoji that is displayed before label
  late final MessageComponentEmoji? emoji;

  /// True of option will be preselected in UI
  late final bool isDefault;

  MessageMultiselectOption._new(Map<String, dynamic> raw) {
    this.label = raw["label"] as String;
    this.value = raw["value"] as String;

    this.description = raw["description"] as String?;
    if (raw["emoji"] != null) {
      this.emoji = MessageComponentEmoji._new(raw["emoji"] as Map<String, dynamic>);
    }  else {
      this.emoji = null;
    }
    this.isDefault = raw["default"] as bool? ?? false;
  }
}

class MessageMultiselect extends IMessageComponent {
  @override
  ComponentType get type => ComponentType.select;

  /// A dev-defined unique string sent on click (max 100 characters)
  late final String customId;

  /// Custom placeholder when no option selected
  late final String? placeholder;

  /// Min value of selected options
  late final int minValues;

  /// Max value of selected options
  late final int maxValues;

  /// Possible options of multiselect
  late final Iterable<MessageMultiselectOption> options;

  MessageMultiselect._new(Map<String, dynamic> raw): super._new() {
    this.customId = raw["custom_id"] as String;
    this.placeholder = raw["placeholder"] as String?;
    this.minValues = raw["min_values"] as int? ?? 1;
    this.maxValues= raw["max_values"] as int? ?? 1;
    this.options = [
      for (final rawOption in raw["options"])
        MessageMultiselectOption._new(rawOption as Map<String, dynamic>)
    ];
  }
}

/// Button component for Message
class IMessageButton extends IMessageComponent {
  @override
  ComponentType get type => ComponentType.button;

  /// What the button says (max 80 characters)
  late final String label;

  /// Component style, appearance
  late final ComponentStyle style;

  /// Additional emoji that will be displayed before label
  late final MessageComponentEmoji? emoji;

  /// True if button is disabled
  late final bool disabled;

  factory IMessageButton._deserialize(RawApiMap raw) {
    if (raw["style"] == ComponentStyle.link.value) {
      return LinkMessageButton._new(raw);
    }

    return MessageButton._new(raw);
  }

  IMessageButton._new(Map<String, dynamic> raw): super._new() {
    this.label = raw["label"] as String;
    this.style = ComponentStyle.from(raw["style"] as int);

    if (raw["emoji"] != null) {
      this.emoji = MessageComponentEmoji._new(raw["emoji"] as RawApiMap);
    }  else {
      this.emoji = null;
    }

    this.disabled = raw["disabled"] as bool? ?? false;
  }
}

/// Represents button that has attached metadata and will generate interaction event
class MessageButton extends IMessageButton {
  ///  a dev-defined unique string sent on click (max 100 characters)
  late final String customId;

  MessageButton._new(RawApiMap raw): super._new(raw) {
    this.customId = raw["custom_id"] as String;
  }
}

/// Button with a link that user will be redirected after clicking
class LinkMessageButton extends IMessageButton {
  /// Url where button points
  late final String url;

  /// buttons url as [Uri]
  Uri get uri => Uri.parse(url);

  LinkMessageButton._new(RawApiMap raw): super._new(raw) {
    this.url = raw["url"] as String;
  }
}
