part of nyxx_interactions;

/// Used to make multiple methods of checking if the slash commands have been edited since last update
abstract class ICommandsSync {
  /// Should the commands & perms be synced?
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands);
}
