part of discord;

/// Command interface to unify.
abstract class ICommand {
  /// Function which will be invoked when command triggers
  Future run(Message message);
}
