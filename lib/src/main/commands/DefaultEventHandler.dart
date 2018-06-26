part of discord;

class DefaultEventHandler implements EventHandler {
  @override
  Future commandNotFound(Message message) {}

  @override
  Future forAdminOnly(Message message) {}

  @override
  Future requiredPermission(Message message) {}
}
