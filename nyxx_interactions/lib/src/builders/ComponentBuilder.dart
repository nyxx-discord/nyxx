part of nyxx_interactions;

/// Type of interaction component
class ComponentType extends IEnum {
  /// Row where other components can be placed
  static const ComponentType row = const ComponentType._create(1);

  static const ComponentType button = const ComponentType._create(2);
  static const ComponentType select = const ComponentType._create(3);

  const ComponentType._create(value) : super(value);
  /// Create [ComponentType] from [value]
  ComponentType.from(value) : super(value);
}

/// Allows to create components
abstract class IComponentBuilder extends Builder {
  /// Type of component
  ComponentType get type;

  Map<String, dynamic> build() => {
    "type": this.type.value,
  };
}

class DropdownOptionBuilder extends Builder {
  /// User-facing name of the option
  final String label;

  /// Internal value of option
  final String value;

  /// Setting to true will render this option as pre-selected
  final bool isDefault;

  /// An additional description to option
  String? description;

  /// Emoji displayed alongside with label
  IEmoji? emoji;

  /// Creates instance of [DropdownOptionBuilder]
  DropdownOptionBuilder(this.label, this.value, [this.isDefault = false]);

  @override
  Map<String, dynamic> build() => {
    "label": this.label,
    "value": this.value,
    "default": this.isDefault,
    if (this.emoji != null) "emoji": {
      if (this.emoji is IGuildEmoji) "id": (this.emoji as IGuildEmoji).id,
      if (this.emoji is UnicodeEmoji) "name": (this.emoji as UnicodeEmoji).code,
      if (this.emoji is GuildEmoji) "animated": (this.emoji as GuildEmoji).animated,
    },
    if (description != null) "description": this.description,
  };
}

class DropdownBuilder extends IComponentBuilder {
  @override
  ComponentType get type => ComponentType.select;

  /// Max: 100 characters
  final String customId;

  /// Max: 25
  final List<DropdownOptionBuilder> options;

  /// Custom placeholder when nothing selected
  String? placeholder;

  /// Minimum number of options that can be chosen.
  /// Default: 1, min: 1, max: 25
  int? minValues;

  /// Maximum numbers of options that can be chosen
  /// Default: 1, min: 1, max: 25
  int? maxValues;

  /// Creates instance of [DropdownBuilder]
  DropdownBuilder(this.customId, [this.options = const []]) {
    if (this.customId.length > 100) {
      throw ArgumentError("Custom Id for Select cannot have more than 100 characters");
    }
  }

  /// Adds option to dropdown
  void addOption(DropdownOptionBuilder builder) => this.options.add(builder);

  @override
  Map<String, dynamic> build() => {
    ...super.build(),
    "custom_id": this.customId,
    "options": [
      for (final optionBuilder in this.options)
        optionBuilder.build()
    ],
    if (placeholder != null) "placeholder": this.placeholder,
    if (minValues != null) "min_values": this.minValues,
    if (maxValues != null) "max_values": this.maxValues,
  };
}

/// Allows to build button. Generic interface for all types of buttons
abstract class IButtonBuilder extends IComponentBuilder {
  @override
  ComponentType get type => ComponentType.button;

  /// Label for button. Max 80 characters.
  final String label;

  /// Style of button. See [ComponentStyle]
  final ComponentStyle style;

  /// True if emoji is disabled
  bool disabled = false;

  /// Additional emoji for button
  IEmoji? emoji;

  /// Creates instance of [IButtonBuilder]
  IButtonBuilder(this.label, this.style, {this.disabled = false, this.emoji}) {
    if (this.label.length > 80) {
      throw ArgumentError("Label for Button cannot have more than 80 characters");
    }
  }

  @override
  Map<String, dynamic> build() => {
    ...super.build(),
    "label": this.label,
    "style": this.style.value,
    if (this.disabled) "disabled": true,
    if (this.emoji != null) "emoji": {
      if (this.emoji is IGuildEmoji) "id": (this.emoji as IGuildEmoji).id,
      if (this.emoji is UnicodeEmoji) "name": (this.emoji as UnicodeEmoji).code,
      if (this.emoji is GuildEmoji) "animated": (this.emoji as GuildEmoji).animated,
    }
  };
}

/// Allows to create a button with link
class LinkButtonBuilder extends IButtonBuilder {
  /// Url where his button should redirect
  final String url;

  /// Creates instance of [LinkButtonBuilder]
  LinkButtonBuilder(
      String label,
      this.url,
      {bool disabled = false,
        IEmoji? emoji
      }): super(label, ComponentStyle.link, disabled: disabled, emoji: emoji
  ) {
    if (this.url.length > 512) {
      throw ArgumentError("Url for button cannot have more than 512 characters");
    }
  }

  @override
  Map<String, dynamic> build() => {
    ...super.build(),
    "url": url
  };
}

/// Button which will generate event when clicked.
class ButtonBuilder extends IButtonBuilder {
  /// Id with optional additional metadata for button.
  String customId;

  /// Creates instance of [ButtonBuilder]
  ButtonBuilder(
      String label,
      this.customId,
      ComponentStyle style,
      {bool disabled = false,
        IEmoji? emoji
      }) : super(label, style, disabled: disabled, emoji: emoji
  ) {
    if (this.label.length > 100) {
      throw ArgumentError("customId for button cannot have more than 100 characters");
    }
  }

  @override
  Map<String, dynamic> build() => {
    ...super.build(),
    "custom_id": customId
  };
}

/// Extended [MessageBuilder] with support for buttons
class ComponentMessageBuilder extends MessageBuilder {
  /// Set of buttons to attach to message. Message can only have 5 rows with 5 buttons each.
  List<List<IComponentBuilder>>? components;

  /// Allows to add
  void addButtonRow(List<IComponentBuilder> buttons) {
    if (this.components == null) {
      this.components = [];
    }

    if (buttons.length > 5 || buttons.isEmpty) {
      throw ArgumentError("Button row cannot be empty or have more than 5 buttons");
    }

    if (this.components!.length == 5) {
      throw ArgumentError("Buttons cannot have more than 5 rows of buttons");
    }

    this.components!.add(buttons);
  }

  @override
  Map<String, dynamic> build(INyxx client) => {
    ...super.build(client),
    if (this.components != null) "components": [
      for (final row in this.components!)
        {
          "type": ComponentType.row.value,
          "components": [
            for (final component in row)
              component.build()
          ]
        }
    ]
  };
}
