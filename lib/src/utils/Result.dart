import 'dart:async';

class Optional<T> {
  T _value;

  Optional.of(this._value);

  Optional.compute(T val, T computation(T value)) {
    if (val != null) _value = computation(val);
  }

  T get() {
    if (_value == null) throw ArgumentError("Cannot return null value.");

    return _value;
  }

  T unsafe() => _value;

  T orElse(T computation()) {
    if (_value == null) return computation();

    return _value;
  }

  T or(T value) {
    if (_value == null) return value;

    return _value;
  }

  void then(void consume(T value), [void onNull()]) {
    if (_value == null) {
      if (onNull != null) onNull();
      return;
    }

    consume(_value);
  }
}
