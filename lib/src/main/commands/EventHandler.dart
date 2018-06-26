part of discord;

abstract class EventHandler {
  Future commandNotFound(Message message);
  Future forAdminOnly(Message message);
  Future requiredPermission(Message message);
}
