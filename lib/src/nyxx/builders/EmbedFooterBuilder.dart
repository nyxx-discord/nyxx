part of nyxx;

/// Build new instance of Embed's footer
class EmbedFooterBuilder implements Builder {
  /// Footer text
  String text;

  /// Url of footer icon. Supports only http(s) for now
  String iconUrl;

  /// Length of footer
  int get length => text.length;

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    if(this.length > 2048)
      throw new Exception("Footer text is too long. (1024 characters limit)");

    Map<String, dynamic> tmp = Map();
    if (text != null) tmp["text"] = text;
    if (iconUrl != null) tmp["icon_url"] = iconUrl;

    return tmp;
  }
}
