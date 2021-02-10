part of nyxx_interactions;

class _EventController implements Disposable {
  /// Emitted when a a slash command is sent.
  late final StreamController<InteractionEvent> onSlashCommand;

  /// Emitted when a a slash command is sent.
  late final StreamController<SlashCommand> onSlashCommandCreated;

  _EventController(Interactions _client) {
    this.onSlashCommand = StreamController.broadcast();
    _client.onSlashCommand = this.onSlashCommand.stream;

    this.onSlashCommandCreated = StreamController.broadcast();
    _client.onSlashCommandCreated = this.onSlashCommandCreated.stream;
  }

  @override
  Future<void> dispose() async {
    await this.onSlashCommand.close();
    await this.onSlashCommandCreated.close();
  }
}
