part of nyxx_interactions;

/// The event that you receive when a user types a slash command.
abstract class InteractionEvent<T extends Interaction> {
  /// Reference to [Nyxx]
  Nyxx get client => interactions._client;

  /// Reference to [Interactions]
  late final Interactions interactions;

  /// The interaction data, includes the args, name, guild, channel, etc.
  T get interaction;

  /// The DateTime the interaction was received by the Nyxx Client.
  final DateTime receivedAt = DateTime.now();

  /// If the Client has sent a response to the Discord API. Once the API was received a response you cannot send another.
  bool _hasAcked = false;

  /// Opcode for acknowledging interaction
  int get _acknowledgeOpCode;

  /// Opcode for responding to interaction
  int get _respondOpcode;

  final Logger _logger = Logger("Interaction Event");

  InteractionEvent._new(this.interactions);

  /// Create a followup message for an Interaction
  Future<Message> sendFollowup(MessageBuilder builder) async {
    if (!_hasAcked) {
      return Future.error(ResponseRequiredError());
    }
    this._logger.fine("Sending followup for for interaction: ${this.interaction.id}");

    return this.interactions.interactionsEndpoints.sendFollowup(
        this.interaction.id.toString(),
        builder
    );
  }

  /// Edits followup message
  Future<Message> editFollowup(Snowflake messageId, MessageBuilder builder) =>
    this.interactions.interactionsEndpoints.editFollowup(this.interaction.token, messageId, builder);

  /// Deletes followup message with given id
  Future<void> deleteFollowup(Snowflake messageId) =>
      this.interactions.interactionsEndpoints.deleteFollowup(this.interaction.token, messageId);

  /// Deletes original response
  Future<void> deleteOriginalResponse() =>
      this.interactions.interactionsEndpoints.deleteOriginalResponse(this.interaction.token, this.interaction.id.toString());

  /// Fetch followup message
  Future<Message> fetchFollowup(Snowflake messageId) async =>
    this.interactions.interactionsEndpoints.fetchFollowup(this.interaction.token, messageId);

  /// Used to acknowledge a Interaction but not send any response yet.
  /// Once this is sent you can then only send ChannelMessages.
  /// You can also set showSource to also print out the command the user entered.
  Future<void> acknowledge({bool hidden = false}) async {
    if (_hasAcked) {
      return Future.error(AlreadyRespondedError());
    }

    if (DateTime.now().isAfter(this.receivedAt.add(const Duration(seconds: 3)))) {
      return Future.error(InteractionExpiredError._3secs());
    }

    await this.interactions.interactionsEndpoints.acknowledge(
        this.interaction.token,
        this.interaction.id.toString(),
        hidden,
        this._acknowledgeOpCode
    );

    this._logger.fine("Sending acknowledge for for interaction: ${this.interaction.id}");

    _hasAcked = true;
  }

  /// Used to acknowledge a Interaction and send a response.
  /// Once this is sent you can then only send ChannelMessages.
  Future<void> respond(MessageBuilder builder, {bool hidden = false}) async {
    final now = DateTime.now();
    if (_hasAcked && now.isAfter(this.receivedAt.add(const Duration(minutes: 15)))) {
      return Future.error(InteractionExpiredError._15mins());
    } else if (now.isAfter(this.receivedAt.add(const Duration(seconds: 3)))) {
      return Future.error(InteractionExpiredError._3secs());
    }

    this._logger.fine("Sending respond for for interaction: ${this.interaction.id}");
    if (_hasAcked) {
      await this.interactions.interactionsEndpoints.respondEditOriginal(
          this.interaction.token,
          builder,
          hidden
      );
    } else {
      if (!builder.canBeUsedAsNewMessage()) {
        return Future.error(ArgumentError("Cannot sent message when MessageBuilder doesn't have set either content, embed or files"));
      }

      await this.interactions.interactionsEndpoints.respondCreateResponse(
          this.interaction.token,
          this.interaction.id.toString(),
          builder,
          hidden,
          _respondOpcode
      );
    }

    _hasAcked = true;
  }

  /// Returns [Message] object of original interaction response
  Future<Message> getOriginalResponse() async =>
      this.interactions.interactionsEndpoints.fetchOriginalResponse(this.interaction.token, this.interaction.id.toString());

  /// Edits original message response
  Future<Message> editOriginalResponse(MessageBuilder builder) =>
      this.interactions.interactionsEndpoints.editOriginalResponse(this.interaction.token, builder);
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

  /// Returns args of interaction
  List<InteractionOption> get args => UnmodifiableListView(_extractArgs(this.interaction.options));

  SlashCommandInteractionEvent._new(Interactions interactions, RawApiMap raw) : super._new(interactions) {
    this.interaction = SlashCommandInteraction._new(client, raw);
  }

  /// Searches for arg with [name] in this interaction
  InteractionOption getArg(String name) => args.firstWhere((element) => element.name == name);
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

  ComponentInteractionEvent._new(Interactions interactions, RawApiMap raw) : super._new(interactions);
}

/// Interaction event for button events
class ButtonInteractionEvent extends ComponentInteractionEvent<ButtonInteraction> {
  @override
  late final ButtonInteraction interaction;

  ButtonInteractionEvent._new(Interactions interactions, RawApiMap raw) : super._new(interactions, raw) {
    this.interaction = ButtonInteraction._new(client, raw);
  }
}

/// Interaction event for dropdown events
class MultiselectInteractionEvent extends ComponentInteractionEvent<MultiselectInteraction> {
  @override
  late final MultiselectInteraction interaction;

  MultiselectInteractionEvent._new(Interactions interactions, RawApiMap raw) : super._new(interactions, raw) {
    this.interaction = MultiselectInteraction._new(client, raw);
  }
}
