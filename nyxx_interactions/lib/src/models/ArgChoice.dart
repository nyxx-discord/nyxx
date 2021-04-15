part of nyxx_interactions;

class ArgChoice {
  late final String name;

  late final dynamic value;

  ArgChoice._new(Map<String, dynamic> raw) {
    this.name = raw["name"] as String;
    this.value = raw["value"];
  }
}
