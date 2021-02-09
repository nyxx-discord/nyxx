part of nyxx_interactions;

class InteractionOption {
  final dynamic? value;
  final Map<String, InteractionOption> args = <String, InteractionOption>{};
  InteractionOption._new(this.value, List rawOptions) {
    for(var i = 0; i < rawOptions.length; i++) {
      final el = rawOptions[i];
      this.args[el["name"] as String] = InteractionOption._new(
        el["value"] as dynamic,
        (el["options"] ?? List<dynamic>.empty() ) as List,
      );
    }
  }
}
