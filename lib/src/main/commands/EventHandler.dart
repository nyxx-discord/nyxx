part of discord;

/// Handles dispatch events.
abstract class EventHandler {
  /// Invoked when command isn't found in registry
  Future commandNotFound(Message message);

  /// Invoked when command for admins is invoked by non-admin user
  Future forAdminOnly(Message message);

  /// Invoked when command is invoked by user without needed permissions(roles)
  Future requiredPermission(Message message);
}
