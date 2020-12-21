part of nyxx_interactions;

class CommandInteractionOption {
  final String name;
  final int? value;
  final List<CommandInteractionOption>? options;
  CommandInteractionOption._new(this.name, this.value, this.options);
}
