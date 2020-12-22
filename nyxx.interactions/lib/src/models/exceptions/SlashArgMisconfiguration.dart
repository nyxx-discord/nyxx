part of nyxx_interactions;

/// Thrown when your slash are is configured in a way that is not possible
class SlashArgMisconfiguration implements Error {
  /// The params that are incorrect.
  late final String params;

  SlashArgMisconfiguration._new(this.params);

  /// Returns a string representation of this object.
  @override
  String toString() =>
      "SlashArgMisconfigurationError: ${this.params} are mismatched. Please refer to the nyxx.interaction docs and the discord developer docs to make sure that all your slash args arguments are compatible together.";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
