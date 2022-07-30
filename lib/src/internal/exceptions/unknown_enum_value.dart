/// Thrown when a parsing method of an enum failed.
class UnknownEnumValueError extends Error {
  final Object value;

  /// Creates a new instance of [UnknownEnumValueError].
  UnknownEnumValueError(this.value);

  @override
  String toString() => 'Unknown enum value: ${Error.safeToString(value)}';
}
