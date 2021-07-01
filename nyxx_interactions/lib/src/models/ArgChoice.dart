part of nyxx_interactions;

/// Choice that user can pick from. For [CommandOptionType.integer] or [CommandOptionType.string]
class ArgChoice {
  /// Name of choice
  late final String name;

  /// Value of choice
  late final dynamic value;

  ArgChoice._new(RawApiMap raw) {
    this.name = raw["name"] as String;
    this.value = raw["value"];
  }
}
