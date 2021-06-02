part of nyxx;

/// Build new instance of Embed's footer
class EmbedFooterBuilder extends Builder {
  /// Footer text
  String? text;

  /// Url of footer icon. Supports only http(s) for now
  String? iconUrl;

  /// Length of footer
  int? get length => text?.length;

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> build() {
    if (this.text != null && this.length! > 2048) {
      throw EmbedBuilderArgumentException._new("Footer text is too long. (1024 characters limit)");
    }

    return <String, dynamic>{if (text != null) "text": text, if (iconUrl != null) "icon_url": iconUrl};
  }
}
