part of nyxx.commander;

bool _isCommandMatching(String command, String message) {
  final commandParts = command.split(" ");
  final messageParts = message.split(" ");

  if (commandParts.length > messageParts.length) {
    return false;
  }

  for (var i = 0; i < commandParts.length; i++) {
    if (commandParts[i].trim() != messageParts[i].trim()) {
      return false;
    }
  }

  return true;
}
