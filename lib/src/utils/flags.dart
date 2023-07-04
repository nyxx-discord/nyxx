import 'dart:collection';

import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A set of flags that can be either enabled or disabled.
class Flags<T extends Flags<T>> extends IterableBase<Flag<T>> with ToStringHelper {
  /// The integer value encoding the flags as a bitfield.
  final int value;

  /// Create a new [Flags].
  const Flags(this.value);

  /// Returns `true` if this [Flags] has the [flag] enabled, `false` otherwise.
  bool has(Flag<T> flag) => value & flag.value != 0;

  @override
  Iterator<Flag<T>> get iterator => _FlagIterator(this);

  /// Return a set of flags that has all the flags set in either `this` or [other].
  Flags<T> operator |(Flags<T> other) => Flags(value | other.value);

  /// Return a set of flags that has all the flags set in both `this` and [other].
  Flags<T> operator &(Flags<T> other) => Flags(value & other.value);

  /// Return a set of flags that has all the flags set in `this` or in `other` but not in both.
  Flags<T> operator ^(Flags<T> other) => Flags(value ^ other.value);

  /// Returns the opposite of this set of flags.
  Flags<T> operator ~() => Flags(~value);

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Flags<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String defaultToString() => 'Flags<$T>($value)';
}

/// A flag within a set of [Flags].
class Flag<T extends Flags<T>> extends Flags<T> {
  /// Create a new [Flag].
  const Flag(super.value);

  /// Create a new [Flag] from an offset into the bitfield.
  const Flag.fromOffset(int offset) : super(1 << offset);

  @override
  String toString() => 'Flag<$T>($value)';
}

class _FlagIterator<T extends Flags<T>> implements Iterator<Flag<T>> {
  final Flags<T> source;

  _FlagIterator(this.source);

  int? offset;

  @override
  bool moveNext() {
    do {
      if (offset == null) {
        offset = 0;
      } else {
        offset = offset! + 1;
      }

      if (offset! > source.value.bitLength) {
        return false;
      }
    } while (!source.has(current));

    return true;
  }

  @override
  Flag<T> get current => Flag<T>.fromOffset(offset!);
}
