part of nyxx;

/// Build new instance of Embed's footer
class EmbedFooterBuilder {
  /// Fotter text
  String text;

  /// Url of footer icon. Supports only http(s) for now
  String iconUrl;

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = new Map();

    if (text != null) tmp["text"] = text;
    if (iconUrl != null) tmp["icon_url"] = iconUrl;

    return tmp;
  }
}
