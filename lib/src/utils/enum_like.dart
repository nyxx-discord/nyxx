base class EnumLike<T extends Object> {
  /// The value this enum-like holds.
  final T value;

  /// Whether this enum-like is unknown.
  final bool isUnknown;

  //@nodoc
  const EnumLike(this.value, [this.isUnknown = false]);

  @override
  String toString() => '$runtimeType($value)';

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object? other) => (other is EnumLike<T> && other.value == value) || (other is T && other == value);
}

R parseEnum<T extends Object, R extends EnumLike<T>>(List<EnumLike<T>> values, T value) {
  final enumValue = values.firstWhere((enumValue) => enumValue.value == value, orElse: () => EnumLike<T>(value, true));
  return enumValue as R;
}
