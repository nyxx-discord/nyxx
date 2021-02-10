part of nyxx_interactions;

/// The option given by the user when sending a command
class InteractionOption {
  /// The value given by the user
  final dynamic? value;

  /// Any args under this as you can have sub commands
  final Map<String, InteractionOption> args = {};

  InteractionOption._new(this.value, List rawOptions) {
    for (final el in rawOptions) {
      this.args[el["name"] as String] = InteractionOption._new(
        el["value"] as dynamic,
        (el["options"] ?? List<dynamic>.empty()) as List,
      );
    }
  }
}
