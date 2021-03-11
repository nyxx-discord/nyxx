part of nyxx_commander;

// TODO: FIX. I think that is just awful but is does its job
extension _CommandMatcher on Iterable<CommandEntity> {
  CommandEntity? _findMatchingCommand(Iterable<String> messageParts) {
    for (final entity in this) {
      if(entity is CommandGroup && entity.name == "") {
        final e = entity._commandEntities._findMatchingCommand(messageParts);

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

        final e = entity._commandEntities._findMatchingCommand(messageParts.skip(1));

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
