part of nyxx_interactions;

Iterable<Iterable<T>> _partition<T>(Iterable<T> list, bool Function(T) predicate) {
  final matches = <T>[];
  final nonMatches = <T>[];

  for(final e in list) {
    if(predicate(e)) {
      matches.add(e);
      continue;
    }

    nonMatches.add(e);
  }

  return [matches, nonMatches];
}

/// Determine what handler should be executed based on [interaction]
String _determineInteractionCommandHandler(Interaction interaction) {
  final commandHash = "${interaction.commandId}|${interaction.name}";

  try {
    final subCommandGroup = interaction.args.firstWhere((element) => element.type == CommandOptionType.subCommandGroup);
    final subCommand = interaction.args.firstWhere((element) => element.type == CommandOptionType.subCommand);

    return "$commandHash${subCommandGroup.name}${subCommand.name}";
    // ignore: empty_catches
  } on Error { }

  try {
    final subCommand = interaction.args.firstWhere((element) => element.type == CommandOptionType.subCommand);
    return "$commandHash${subCommand.name}";
  } on Error {
    return commandHash;
  }
}

/// Groups [SlashCommandBuilder] for registering them later in bulk
Map<Snowflake, Iterable<SlashCommandBuilder>> _groupSlashCommandBuilders(Iterable<SlashCommandBuilder> commands) {
  final commandsMap = <Snowflake, List<SlashCommandBuilder>>{};

  for(final slashCommand in commands) {
    final id = slashCommand.guild!;

    if (commandsMap.containsKey(id)) {
      commandsMap[id]!.add(slashCommand);
      continue;
    }

    commandsMap[id] = [slashCommand];
  }

  return commandsMap;
}
