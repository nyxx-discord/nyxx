part of nyxx_interactions;

class _EventController implements Disposable {
  /// Emitted when a a slash command is sent.
  late final StreamController<SlashCommandInteractionEvent> onSlashCommand;

  /// Emitted when a a slash command is sent.
  late final StreamController<SlashCommand> onSlashCommandCreated;

  /// Emitted when button event is sent
  late final StreamController<ComponentInteractionEvent> onButtonEvent;

  _EventController(Interactions _client) {
    this.onSlashCommand = StreamController.broadcast();
    _client.onSlashCommand = this.onSlashCommand.stream;

    this.onSlashCommandCreated = StreamController.broadcast();
    _client.onSlashCommandCreated = this.onSlashCommandCreated.stream;

    this.onButtonEvent = StreamController.broadcast();
    _client.onButtonEvent = this.onButtonEvent.stream;
  }

  @override
  Future<void> dispose() async {
    await this.onSlashCommand.close();
    await this.onSlashCommandCreated.close();
  }
}
