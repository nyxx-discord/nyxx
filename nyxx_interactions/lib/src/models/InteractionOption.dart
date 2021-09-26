part of nyxx_interactions;

/// The option given by the user when sending a command
class InteractionOption {
  /// The value given by the user
  late final dynamic value;

  /// Type of interaction
  late final CommandOptionType type;

  /// Name of option
  late final String name;

  /// Any args under this as you can have sub commands
  late final Iterable<InteractionOption> options;

  /// True if options is focused
  late final bool isFocused;

  InteractionOption._new(RawApiMap raw) {
    this.value = raw["value"] as dynamic;
    this.name = raw["name"] as String;
    this.type = CommandOptionType(raw["type"] as int);

    if (raw["options"] != null) {
      this.options = (raw["options"] as List<dynamic>).map((e) => InteractionOption._new(e as RawApiMap));
    } else {
      this.options = [];
    }

    this.isFocused = raw["focused"] as bool;
  }
}
