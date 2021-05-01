part of nyxx_interactions;

class ButtonStyle extends IEnum<int> {
  /// A blurple button
  static const primary = ButtonStyle._create(1);
  /// A grey button
  static const secondary = ButtonStyle._create(2);
  /// A green button
  static const success = ButtonStyle._create(3);
  /// A red button
  static const danger = ButtonStyle._create(4);
  /// A button that navigates to a URL
  static const link = ButtonStyle._create(5);

  /// Creates instance of [ButtonStyle]
  ButtonStyle.from(int value) : super(value);
  const ButtonStyle._create(int value) : super(value);
}

abstract class IButtonBuilder extends Builder {
  /// Type of component
  static const type = 2;

  /// Label for button. Max 80 characters.
  final String label;

  /// Style of button. See [ButtonStyle]
  final ButtonStyle style;

  /// True if emoji is disabled
  bool disabled = false;

  /// Additional emoji for button
  IEmoji? emoji;

  IButtonBuilder._new(this.label, this.style, {this.disabled = false, this.emoji}) {
    if (this.label.length > 80) {
      throw ArgumentError("Label for Button cannot have more than 80 characters");
    }
  }

  @override
  Map<String, dynamic> _build() => {
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

class LinkButtonBuilder extends IButtonBuilder {
  /// Url where his button should redirect
  final String url;

  /// Creates instance of [LinkButtonBuilder]
  LinkButtonBuilder(
      String label,
      this.url,
      {bool disabled = false,
        IEmoji? emoji
      }): super._new(label, ButtonStyle.link, disabled: disabled, emoji: emoji
  ) {
    if (this.url.length > 512) {
      throw ArgumentError("Url for button cannot have more than 512 characters");
    }
  }
}

class ButtonBuilder extends IButtonBuilder {
  /// Id with optional additional metadata for button.
  /// Metadata attached with [attachAdditionalMetadata] is delimited by ; after id of button
  String idMetadata;

  /// Creates instance of [ButtonBuilder]
  ButtonBuilder(
      String label,
      this.idMetadata,
      ButtonStyle style,
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
}
