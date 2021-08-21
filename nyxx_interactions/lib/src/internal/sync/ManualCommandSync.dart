part of nyxx_interactions;

/// Manually define command syncing rules
class ManualCommandSync implements ICommandsSync {
  /// If commands & permissions should be overridden on next run.
  final bool sync;

  const ManualCommandSync({this.sync = true});

  @override
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands) => this.sync;
}
