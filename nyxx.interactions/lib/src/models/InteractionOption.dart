part of nyxx_interactions;

/// The option given by the user when sending a command
class InteractionOption {
  /// The value given by the user
  final dynamic? value;

  /// Any args under this as you can have sub commands
  final Map<String, InteractionOption> args = {};

  InteractionOption._new(this.value, List<Map<String, dynamic>> rawOptions) {
    for (final option in rawOptions) {
      this.args[option["name"] as String] = InteractionOption._new(
        option["value"] as dynamic,
        (option["options"] ?? List<Map<String, dynamic>>.empty()) as List<Map<String, dynamic>>,
      );
    }
  }
}
