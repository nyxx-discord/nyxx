part of nyxx.commander;

bool _isCommandMatching(String command, String message) {
  var commandParts = command.split(" ");
  var messageParts = message.split(" ");

  if (commandParts.length > messageParts.length) {
    return false;
  }

  for (var i = 0; i < commandParts.length; i++) {
    if (commandParts[i] != messageParts[i]) {
      return false;
    }
  }

  return true;
}
