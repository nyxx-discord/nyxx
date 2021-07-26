part of nyxx_interactions;

/// Manually define command syncing rules
class ManualCommandsSync implements ICommandsSync {
  /// If commands & permissions should be overridden on next run.
  final bool sync;

  ManualCommandsSync(this.sync);

  @override
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands) => this.sync;
}
