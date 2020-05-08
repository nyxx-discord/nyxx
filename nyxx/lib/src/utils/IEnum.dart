part of nyxx;

abstract class IEnum<T> {
  final T _value;

  T get value => _value;

  const IEnum(this._value);
  
  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) {
    if (other is IEnum<T>) {
      return other._value == this._value;
    }

    if (other is T) {
      return other == this._value;
    }

    return false;
  }
}
