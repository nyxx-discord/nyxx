import 'dart:async';

class Optional<T> {
  T _value;

  Optional.of(this._value);

  Optional.compute(T val, T computation(T value)) {
    if(val != null) _value = computation(val);
  }

  T get() {
    if (_value == null)
      throw ArgumentError("Cannot return null value.");

    return _value;
  }

  T unsafe() => _value;

  T orElse(T computation()) {
    if (_value == null)
      return computation();

    return _value;
  }

  T or(T value) {
    if(_value == null)
      return value;

    return _value;
  }

  void then(void consume(T value), [void onNull()]) {
    if (_value == null) {
      onNull();
      return;
    }

    consume(_value);
  }
}

class Result<T, E> {
  T _result;
  E _error;

  Result.of(this._result);

  Result.error(this._error);

  T get() {
    if(_error == null) {
      if (_error is Exception)
        throw _error;

      throw Exception(_error);
    }

    return _result;
  }

  T orElse([T fallback(E error)]) {
    if(_error == null) {
      if (fallback != null) {
        return fallback(_error);
      }

      if (_error is Exception)
        throw _error;

      throw Exception(_error);
    }

    return _result;
  }
}