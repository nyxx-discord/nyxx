part of nyxx_interactions;

/// The event that you receive when a user types a slash command.
abstract class InteractionEvent<T extends Interaction> {
  late final Nyxx _client;

  final Logger _logger = Logger("Interaction Event");

  /// The interaction data, includes the args, name, guild, channel, etc.
  T get interaction;

  /// The DateTime the interaction was received by the Nyxx Client.
  final DateTime receivedAt = DateTime.now();

  /// If the Client has sent a response to the Discord API. Once the API was received a response you cannot send another.
  bool hasResponded = false;

  /// Opcode for acknowledging interaction
  int get _acknowledgeOpCode;

  /// Opcode for responding to interaction
  int get _respondOpcode;

  InteractionEvent._new(this._client);

  /// Create a followup message for an Interaction
  Future<void> sendFollowup(MessageBuilder builder) async {
    if(!hasResponded) {
      return Future.error(ResponseRequiredError());
    }

    final url = "/webhooks/${this._client.app.id.toString()}/${this.interaction.token}";
    final body = BuilderUtility.buildWithClient(builder, _client);
    this._logger.fine("Sending followup for for interaction: url: [$url]; body: [$body]");

    final response = await this._client.httpEndpoints.sendRawRequest(url, "POST", body: body);

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  /// Used to acknowledge a Interaction but not send any response yet.
  /// Once this is sent you can then only send ChannelMessages.
  /// You can also set showSource to also print out the command the user entered.
  Future<void> acknowledge() async {
    if (DateTime.now().isAfter(this.receivedAt.add(const Duration(seconds: 3)))) {
      return Future.error(InteractionExpiredError());
    }

    if (hasResponded) {
      return Future.error(AlreadyRespondedError());
    }

    final url = "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";
    final response = await this._client.httpEndpoints.sendRawRequest(url, "POST", body: { "type": this._acknowledgeOpCode });

    this._logger.fine("Sending acknowledge for for interaction: $url");

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    hasResponded = true;
  }

  /// Used to acknowledge a Interaction and send a response.
  /// Once this is sent you can then only send ChannelMessages.
  Future<void> respond(MessageBuilder builder, { bool hidden = false }) async {
    if (DateTime.now().isAfter(this.receivedAt.add(const Duration(minutes: 15)))) {
      return Future.error(InteractionExpiredError());
    }

    late String url;
    late RawApiMap body;
    late String method;

    if (hasResponded) {
      url = "/webhooks/${this._client.app.id.toString()}/${this.interaction.token}/messages/@original";
      body = {
        if (hidden) "flags": 1 << 6,
        ...BuilderUtility.buildWithClient(builder, _client)
      };
      method = "PATCH";
    } else {
      if (!builder.canBeUsedAsNewMessage()) {
        return Future.error(ArgumentError("Cannot sent message when MessageBuilder doesn't have set either content, embed or files"));
      }

      url = "/interactions/${this.interaction.id.toString()}/${this.interaction.token}/callback";
      body = <String, dynamic>{
        "type": this._respondOpcode,
        "data": {
          if (hidden) "flags": 1 << 6,
          ...BuilderUtility.buildWithClient(builder, _client)
        },
      };
      method = "POST";
    }
    this._logger.fine("Sending respond for for interaction: url: [$url]; body: [$body]; method: [$method]");

    final response = await this._client.httpEndpoints.sendRawRequest(url, method, body: body,);
    if (response is HttpResponseError) {
      return Future.error(response);
    }

    hasResponded = true;
  }
}

/// Event for slash commands
class SlashCommandInteractionEvent extends InteractionEvent<SlashCommandInteraction> {
  /// Interaction data for slash command
  @override
  late final SlashCommandInteraction interaction;

  @override
  int get _acknowledgeOpCode => 5;

  @override
  int get _respondOpcode => 4;

  SlashCommandInteractionEvent._new(Nyxx client, RawApiMap raw): super._new(client) {
    this.interaction = SlashCommandInteraction._new(client, raw);
  }
}

/// Generic event for component interactions
abstract class ComponentInteractionEvent<T extends ComponentInteraction> extends InteractionEvent<T> {
  /// Interaction data for slash command
  @override
  late final T interaction;

  @override
  int get _acknowledgeOpCode => 6;

  @override
  int get _respondOpcode => 7;

  ComponentInteractionEvent._new(Nyxx client, RawApiMap raw): super._new(client);
}

/// Interaction event for button events
class ButtonInteractionEvent extends ComponentInteractionEvent<ButtonInteraction> {
  @override
  late final ButtonInteraction interaction;

  ButtonInteractionEvent._new(Nyxx client, RawApiMap raw): super._new(client, raw) {
    this.interaction = ButtonInteraction._new(client, raw);
  }
}

/// Interaction event for dropdown events
class MultiselectInteractionEvent extends ComponentInteractionEvent<MultiselectInteraction> {
  @override
  late final MultiselectInteraction interaction;

  MultiselectInteractionEvent._new(Nyxx client, RawApiMap raw): super._new(client, raw) {
    this.interaction = MultiselectInteraction._new(client, raw);
  }
}
