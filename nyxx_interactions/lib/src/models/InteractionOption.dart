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
  late final Iterable<InteractionOption> args;

  /// Option choices
  late final Iterable<ArgChoiceBuilder> choices;

  InteractionOption._new(Map<String, dynamic> raw) {
    this.value = raw["value"] as dynamic;
    this.name = raw["name"] as String;
    this.type = CommandOptionType(raw["type"] as int);

    if (raw["options"] != null) {
      this.args = (raw["options"] as List<dynamic>).map((e) => InteractionOption._new(e as Map<String, dynamic>));
    } else {
      this.args = [];
    }

    if (raw["choices"] != null) {
      this.choices =
          (raw["options"] as List<Map<String, dynamic>>).map((e) => ArgChoiceBuilder(e["name"] as String, e["value"]));
    } else {
      this.choices = [];
    }
  }
}
