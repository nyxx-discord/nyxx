part of nyxx_commander;

class  _CommandMatcher {
  static CommandEntity? _findMatchingCommand(Iterable<String> messageParts, Iterable<CommandEntity> commands) {
    for (final entity in commands) {
      if(entity is CommandGroup && entity.name == "") {
        final e = _findMatchingCommand(messageParts, entity._commandEntities);

        if(e != null) {
          return e;
        }
      }

      if(entity is CommandGroup && entity.isEntityName(messageParts.first)) {
        if (messageParts.length == 1 && entity.defaultHandler != null) {
          return entity.defaultHandler;
        } else if (messageParts.length == 1 && entity.defaultHandler == null) {
          return null;
        }

        final e = _findMatchingCommand(messageParts.skip(1), entity._commandEntities);

        if(e != null) {
          return e;
        }
      }

      if(entity is CommandHandler && entity.isEntityName(messageParts.first)) {
        return entity;
      }
    }

    return null;
  }
}
