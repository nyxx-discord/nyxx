part of nyxx;

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
  /// Component type. For button will be always 2.
  static const type = 2;

  /// What the button says (max 80 characters)
  late final String label;

  /// Component style, appearance
  late final ComponentStyle style;

  /// Additional emoji that will be displayed before label
  late final MessageComponentEmoji? emoji;

  /// True if button is disabled
  late final bool disabled;

  IMessageComponent._new(RawApiMap raw) {
    this.label = raw["label"] as String;
    this.style = ComponentStyle.from(raw["style"] as int);

    if (raw["emoji"] != null) {
      this.emoji = MessageComponentEmoji._new(raw["emoji"] as RawApiMap);
    }  else {
      this.emoji = null;
    }

    this.disabled = raw["disabled"] as bool? ?? false;
  }

  factory IMessageComponent._deserialize(RawApiMap raw) {
    if (raw["style"] == ComponentStyle.link.value) {
      return LinkMessageButton._new(raw);
    }

    return MessageButton._new(raw);
  }
}

/// Represents button that has attached metadata and will generate interaction event
class MessageButton extends IMessageComponent {
  ///  a dev-defined unique string sent on click (max 100 characters)
  late final String buttonMetadata;

  MessageButton._new(RawApiMap raw): super._new(raw) {
    this.buttonMetadata = raw["custom_id"] as String;
  }
}

/// Button with a link that user will be redirected after clicking
class LinkMessageButton extends IMessageComponent {
  /// Url where button points
  late final String url;

  /// buttons url as [Uri]
  Uri get uri => Uri.parse(url);

  LinkMessageButton._new(RawApiMap raw): super._new(raw) {
    this.url = raw["url"] as String;
  }
}
