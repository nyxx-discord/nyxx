/// Thrown when a parsing method of an enum failed.
class UnknownEnumValue extends Error {
  final Object value;

  /// Creates a new instance of [UnknownEnumValue].
  UnknownEnumValue(this.value);

  @override
  String toString() => 'Unknown enum value: ${Error.safeToString(value)}';
}
