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

  InteractionEvent._new(Nyxx client, Map<String, dynamic> rawJson) {
    this._client = client;
    interaction = Interaction._new(client, rawJson);

    if (interaction.type == 1) {
      this._pong();
    }
  }

  /// Should be sent when you receive a ping from interactions. Used to acknowledge a ping. Internal to the InteractionEvent.
  Future<void> _pong() async {
    if (DateTime.now().isBefore(this.receivedAt.add(const Duration(minutes: 15)))) {
      if (!hasResponded) {
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

        if (!hasResponded) {
          hasResponded = true;
        }
      } else {
        return Future.error(InteractionExpired());
      }
    } else {
      return Future.error(InteractionExpired());
    }
  }

  /// Used to acknowledge a Interaction but not send any response yet. Once this is sent you can then only send ChannelMessages. You can also set showSource to also print out the command the user entered.
  Future<void> acknowledge({ bool showSource = false, }) async {
    if (DateTime.now().isBefore(this.receivedAt.add(const Duration(minutes: 15)))) {
      if (hasResponded) {
        return Future.error(AlreadyResponded());
      }
      final url = "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";

      final response = await this._client.httpEndpoints.sendRawRequest(
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
    } else {
      return Future.error(InteractionExpired());
    }
  }

  /// Used to acknowledge a Interaction and send a response. Once this is sent you can then only send ChannelMessages. You can also set showSource to also print out the command the user entered.
  Future<void> reply({ dynamic content, EmbedBuilder? embed, bool? tts, AllowedMentions? allowedMentions, bool showSource = false, }) async {
    if (DateTime.now().isBefore(this.receivedAt.add(const Duration(minutes: 15)))) {
      String url;
      if (hasResponded) {
        url = "/webhooks/${this.interaction.id.toString()}/${this.interaction.token}";
      } else {
        url = "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";
      }
      final response = await this._client.httpEndpoints.sendRawRequest(
        url,
        "POST",
        body: {
          "type": showSource ? 4 : 3,
          "data": {
            "content": content,
            "embeds": embed != null ? [BuilderUtility.buildRawEmbed(embed)] : null,
            "allowed_mentions":
                allowedMentions != null ? BuilderUtility.buildRawAllowedMentions(allowedMentions) : null,
            "tts": content != null && tts != null && tts
          },
        },
      );

      if (response is HttpResponseError) {
        return Future.error(response);
      }

      if (!hasResponded) {
        hasResponded = true;
      }
    } else {
      return Future.error(InteractionExpired());
    }
  }
}
