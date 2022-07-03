/// Thrown when a parsing method of an enum failed.
class UnknownEnumValue implements Error {
  final String value;

  @override
  StackTrace? get stackTrace => StackTrace.empty;

  /// Creates a new instance of [UnknownEnumValue].
  const UnknownEnumValue(this.value);

  @override
  String toString() => 'Unknown enum value: $value';
}
