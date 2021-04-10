part of nyxx_interactions;

/// The event that you receive when a user types a slash command.
class InteractionEvent {
  late final Nyxx _client;

  /// The interaction data, includes the args, name, guild, channel, etc.
  late final Interaction interaction;

  /// The DateTime the interaction was received by the Nyxx Client.
  final DateTime receivedAt = DateTime.now();

  /// If the Client has sent a response to the Discord API. Once the API was received a response you cannot send another.
  bool hasResponded = false;

  /// Returns subcommand or null if not subcommand
  InteractionOption? get subCommand {
    if (this.interaction.args.isEmpty) {
      return null;
    }

    try {
      return this.interaction.args.firstWhere((element) => element.type == CommandArgType.subCommand);
    } on Error {
      return null;
    }
  }

  InteractionEvent._new(this._client, Map<String, dynamic> rawJson) {
    this.interaction = Interaction._new(this._client, rawJson);

    if (this.interaction.type == 1) {
      this._pong();
    }
  }

  /// Used to acknowledge a Interaction but not send any response yet.
  /// Once this is sent you can then only send ChannelMessages.
  /// You can also set showSource to also print out the command the user entered.
  Future<void> acknowledge() async {
    if (DateTime.now().isAfter(this.receivedAt.add(const Duration(minutes: 15)))) {
      return Future.error(InteractionExpiredError());
    }

    if (hasResponded) {
      return Future.error(AlreadyRespondedError());
    }

    final url = "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";

    final response = await this._client.httpEndpoints.sendRawRequest(
      url,
      "POST",
      body: {
        "type": 5,
        "data": null,
      },
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    hasResponded = true;
  }

  /// Used to acknowledge a Interaction and send a response.
  /// Once this is sent you can then only send ChannelMessages.
  /// You can also set showSource to also print out the command the user entered.
  Future<void> respond({ dynamic content, EmbedBuilder? embed, bool? tts, AllowedMentions? allowedMentions, bool hidden = false}) async {
    if (DateTime.now().isAfter(this.receivedAt.add(const Duration(minutes: 15)))) {
      return Future.error(InteractionExpiredError());
    }

    late String url;
    late Map<String, dynamic> body;
    late String method;

    if (hasResponded) {
      url = "/webhooks/${this._client.app.id.toString()}/${this.interaction.token}/messages/@original";
      body = <String, dynamic> {
        "content": content,
        "embeds": embed != null ? [BuilderUtility.buildRawEmbed(embed)] : null,
        "allowed_mentions":
        allowedMentions != null ? BuilderUtility.buildRawAllowedMentions(allowedMentions) : null,
        "tts": content != null && tts != null && tts
      };
      method = "PATCH";
    } else {
      url = "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";
      body = <String, dynamic>{
        "type": 4,
        "data": {
          if (hidden) "flags": 1 << 6,
          "content": content,
          "embeds": embed != null ? [BuilderUtility.buildRawEmbed(embed)] : null,
          "allowed_mentions":
          allowedMentions != null ? BuilderUtility.buildRawAllowedMentions(allowedMentions) : null,
          "tts": content != null && tts != null && tts
        },
      };
      method = "POST";
    }

    final response = await this._client.httpEndpoints.sendRawRequest(
      url,
      method,
      body: body,
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    hasResponded = true;
  }

  /// Create a followup message for an Interaction
  Future<void> sendFollowup({ dynamic content, EmbedBuilder? embed, bool? tts, AllowedMentions? allowedMentions, bool hidden = false}) async {
    final url = "/webhooks/${this._client.app.id.toString()}/${this.interaction.token}";
    final body = <String, dynamic> {
      "content": content,
      "embeds": embed != null ? [BuilderUtility.buildRawEmbed(embed)] : null,
      "allowed_mentions":
      allowedMentions != null ? BuilderUtility.buildRawAllowedMentions(allowedMentions) : null,
      "tts": content != null && tts != null && tts
    };

    final response = await this._client.httpEndpoints.sendRawRequest(
      url,
      "POST",
      body: body,
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  /// Should be sent when you receive a ping from interactions.
  /// Used to acknowledge a ping. Internal to the InteractionEvent.
  Future<void> _pong() async {
    if (DateTime.now().isAfter(this.receivedAt.add(const Duration(minutes: 15)))) {
      return Future.error(InteractionExpiredError());
    }

    if (hasResponded) {
      return Future.error(InteractionExpiredError());
    }

    final response = await this._client.httpEndpoints.sendRawRequest(
      "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback",
      "POST",
      body: {
        "type": 1,
        "data": null,
      },
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    hasResponded = true;
  }
}
