part of discord;

/// A webhook client.
class WebhookClient {
  /// The HTTP client.
  _Http http;

  /// The version.
  String version = _Constants.version;

  /// Emitted when data is received about the webhook and all properties are filled.
  Stream<Webhook> onReady;

  /// The webhook;
  Webhook webhook;

  /// Sets up a new webhook client.
  WebhookClient({url, id, token}) {
    StreamController<Webhook> onReady = new StreamController.broadcast();
    this.onReady = onReady.stream;
    this.http = new _Http(this);
    if (url == null) {
      this.http.host = "https://discordapp.com/api/webhooks/$id/$token";
    } else {
      this.http.host = url;
    }

    this.http.get("").then((_HttpResponse r) {
      this.webhook = new Webhook._new(null, r.json as Map<String, dynamic>);
      onReady.add(this.webhook);
    });
  }

  /// Sends a message with the webhook.
  Future<Null> sendMessage(
      {String content,
      List<Map<String, dynamic>> embeds,
      String username,
      String avatarUrl,
      bool tts}) async {
    await this.http.post("", {
      "content": content,
      "username": username,
      "avatar_url": avatarUrl,
      "tts": tts,
      "embeds": embeds
    });
    return null;
  }

  /// Deletes the webhook.
  Future<Null> delete() async {
    await this.http.delete("");
    return null;
  }

  /// Edits the webhook.
  Future<Webhook> edit({String name, List<int> avatar}) async {
    _HttpResponse r =
        await this.http.patch("", {"name": name, "avatar": avatar});
    this.webhook = new Webhook._new(null, r.json as Map<String, dynamic>);
    return this.webhook;
  }
}
