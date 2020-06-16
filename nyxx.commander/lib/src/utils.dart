part of nyxx.commander;

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

      if(entity is CommandGroup && entity.name == messageParts.first) {
        final e = entity._commandEntities._findMatchingCommand(messageParts.skip(1));

        if(e != null) {
          return e;
        }
      }

      if(entity is CommandHandler && entity.name == messageParts.first) {
        return entity;
      }
    }

    return null;
  }
}