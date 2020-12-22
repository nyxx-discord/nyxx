part of nyxx_interactions;

class _EventController implements Disposable {
  /// Emitted when a a slash command is sent.
  late final StreamController<InteractionEvent> onSlashCommand;

  _EventController(Interactions _client) {
    this.onSlashCommand = StreamController.broadcast();
    _client.onSlashCommand = this.onSlashCommand.stream;
  }

  @override
  Future<void> dispose() async {
    await this.onSlashCommand.close();
  }
}
