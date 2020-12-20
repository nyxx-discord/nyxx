part of nyxx_interactions;

class CommandInteractionData {
  final Snowflake id;

  final String name;

  final List<CommandInteractionOption>? options;

  CommandInteractionData._new(this.id, this.name, this.options);
}
