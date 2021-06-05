part of nyxx_interactions;

/// Allows to build button. Generic interface for all types of buttons
abstract class IComponentBuilder extends Builder {
  /// Type of component
  static const type = 2;

  /// Label for button. Max 80 characters.
  final String label;

  /// Style of button. See [ComponentStyle]
  final ComponentStyle style;

  /// True if emoji is disabled
  bool disabled = false;

  /// Additional emoji for button
  IEmoji? emoji;

  IComponentBuilder._new(this.label, this.style, {this.disabled = false, this.emoji}) {
    if (this.label.length > 80) {
      throw ArgumentError("Label for Button cannot have more than 80 characters");
    }
  }

  /// Builds instance of [IComponentBuilder]
  Map<String, dynamic> build() => {
    "type": type,
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
class LinkButtonBuilder extends IComponentBuilder {
  /// Url where his button should redirect
  final String url;

  /// Creates instance of [LinkButtonBuilder]
  LinkButtonBuilder(
      String label,
      this.url,
      {bool disabled = false,
        IEmoji? emoji
      }): super._new(label, ComponentStyle.link, disabled: disabled, emoji: emoji
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
class ButtonBuilder extends IComponentBuilder {
  /// Id with optional additional metadata for button.
  /// Metadata attached with [attachAdditionalMetadata] is delimited by ; after id of button
  String idMetadata;

  /// Creates instance of [ButtonBuilder]
  ButtonBuilder(
      String label,
      this.idMetadata,
      ComponentStyle style,
      {bool disabled = false,
        IEmoji? emoji
      }
      ) : super._new(label, style, disabled: disabled, emoji: emoji) {
    if (this.label.length > 100) {
      throw ArgumentError("IdMetadata for button cannot have more than 100 characters");
    }
  }

  /// Attaches additional metadata to [idMetadata].
  /// Attached metadata is delimited by ';' after first specified id
  void attachAdditionalMetadata(String metadata) {
    if (metadata.length + this.idMetadata.length > 99) {
      throw ArgumentError("IdMetadata for button cannot have more than 100 characters");
    }

    this.idMetadata += ";$metadata";
  }

  @override
  Map<String, dynamic> build() => {
    ...super.build(),
    "custom_id": idMetadata
  };
}

/// Extended [MessageBuilder] with support for buttons
class ComponentMessageBuilder extends MessageBuilder {
  /// Set of buttons to attach to message. Message can only have 5 rows with 5 buttons each.
  List<List<IComponentBuilder>>? buttons;

  /// Allows to add
  void addButtonRow(List<IComponentBuilder> buttons) {
    if (this.buttons == null) {
      this.buttons = [];
    }

    if (buttons.length > 5 || buttons.isEmpty) {
      throw ArgumentError("Button row cannot be empty or have more than 5 buttons");
    }

    if (this.buttons!.length == 5) {
      throw ArgumentError("Buttons cannot have more than 5 rows of buttons");
    }

    this.buttons!.add(buttons);
  }

  @override
  Map<String, dynamic> build(INyxx client) => {
    ...super.build(client),
    if (this.buttons != null) "components": [
      for (final row in this.buttons!)
        {
          "type": 1,
          "components": [
            for (final button in row)
              button.build()
          ]
        }
    ]
  };
}
