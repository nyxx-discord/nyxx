part of nyxx_interactions;

/// Thrown when your slash are is configured in a way that is not possible
class ArgLength implements Error {
  /// The max length for the incorrect length variable/param.
  late final String maxLength;

  /// The min length for the incorrect length variable/param.
  late final String minLength;

  /// The name of the incorrect length variable/param.
  late final String name;

  ArgLength._new(this.name, this.minLength, this.maxLength);

  /// Returns a string representation of this object.
  @override
  String toString() =>
      "ArgLengthError: $name isn't the correct length. It must be larger than $minLength and smaller than $maxLength ($minLength-$maxLength)";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
