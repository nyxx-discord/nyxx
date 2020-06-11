part of nyxx.commander;

// TODO: FIX. I think that is just awful but is does its job

// ignore: public_member_api_docs
extension _CommandMatcher on Iterable<CommandEntity> {
  // ignore: public_member_api_docs
  CommandEntity? _findMatchingCommand(Iterable<String> messageParts) {
    for (final entity in this) {
      if(entity.name == "") {
        return (entity as CommandGroup)._commandEntities._findMatchingCommand(messageParts);
      }

      if(messageParts.isEmpty) {
        if(entity is CommandGroup) {
          return entity.defaultHandler;
        }

        return null;
      }

      if (entity.name != messageParts.first) {
        continue;
      }

      if (entity is CommandHandler) {
        return entity;
      }

      if (entity is CommandGroup) {
        if(entity.parent != null) {
          final subGroupEntity = entity.parent!._commandEntities._findMatchingCommand(messageParts.skip(1));

          if(subGroupEntity != null) {
            if(subGroupEntity is CommandGroup) {
              return subGroupEntity._commandEntities._findMatchingCommand(messageParts.skip(2));
            }

            return subGroupEntity;
          }
        }

        final subEntity = entity._commandEntities._findMatchingCommand(messageParts.skip(1));

        if(subEntity == null && entity.defaultHandler != null) {
          return entity.defaultHandler;
        }

        if(subEntity is CommandGroup) {
          return subEntity._commandEntities._findMatchingCommand(messageParts.skip(2));
        }

        return subEntity;
      }
    }

    return null;
  }
}