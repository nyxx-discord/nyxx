part of nyxx_interactions;

class InteractionEvent {
  late final Nyxx _client;
  late final Interaction interaction;
  final DateTime recievedAt = DateTime.now();
  bool hasResponded = false;

  InteractionEvent._new(Nyxx client, Map<String, dynamic> rawJson) {
    this._client = client;
    interaction = Interaction._new(client, rawJson);

    if(interaction.type == 1) {
      this._pong();
    }
  }

  /// Should be sent when you receive a ping from interactions. Used to acknowledge a ping.
  Future _pong() {
    if (DateTime.now()
        .isBefore(this.recievedAt.add(const Duration(minutes: 15)))) {
      if (!hasResponded) {
        final response = this._client.httpEndpoints.sendRawRequest(
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

        if (!hasResponded) {
          hasResponded = true;
        }
        return Future.value(null);
      } else {
        return Future.error(InteractionExpired());
      }
    } else {
      return Future.error(InteractionExpired());
    }
  }

  /// Used to acknowledge a Interaction but not send any response yet. Once this is sent you can then only send ChannelMessages with or without source.
  Future acknowledge({
    bool showSource = false,
  }) {
    if (DateTime.now()
        .isBefore(this.recievedAt.add(const Duration(minutes: 15)))) {
      if (hasResponded) {
        return Future.error(AlreadyResponded());
      }
      final url =
          "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";

      final response = this._client.httpEndpoints.sendRawRequest(
        url,
        "POST",
        body: {
          "type": showSource ? 5 : 2,
          "data": null,
        },
      );

      if (response is HttpResponseError) {
        return Future.error(response);
      }

      if (!hasResponded) {
        hasResponded = true;
      }

      return Future.value(null);
    } else {
      return Future.error(InteractionExpired());
    }
  }

  Future reply({
    dynamic content,
    EmbedBuilder? embed,
    bool? tts,
    AllowedMentions? allowedMentions,
    bool showSource = false,
  }) async {
    if (DateTime.now()
        .isBefore(this.recievedAt.add(const Duration(minutes: 15)))) {
      String url;
      if (hasResponded) {
        url =
        "/webhooks/${this.interaction.id.toString()}/${this.interaction.token}";
      } else {
        url =
        "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";
      }
      final response = await this._client.httpEndpoints.sendRawRequest(
        url,
        "POST",
        body: {
          "type": showSource ? 4 : 3,
          "data": {
            "content": content,
            "embeds": embed != null ? [ BuilderUtility.buildRawEmbed(embed) ] : null,
            "allowed_mentions": allowedMentions != null
                ? BuilderUtility.buildRawAllowedMentions(allowedMentions)
                : null,
            "tts": content != null && tts != null && tts
          },
        },
      );

      if (response is HttpResponseError) {
        return Future.error(response);
      }

      print((response as HttpResponseSuccess).body);

      if (!hasResponded) {
        hasResponded = true;
      }
      return Future.value(null);
    } else {
      return Future.error(InteractionExpired());
    }
  }
}
