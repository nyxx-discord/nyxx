/// A set of flags that can be either enabled or disabled.
class Flags<T extends Flags<T>> {
  /// The integer value encoding the flags as a bitfield.
  final int value;

  /// Create a new [Flags].
  const Flags(this.value);

  /// Returns `true` if this [Flags] has the [flag] enabled, `false` otherwise.
  bool has(Flag<T> flag) => value & flag.value != 0;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Flags<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// A flag within a set of [Flags].
class Flag<T extends Flags<T>> {
  /// The value of this flag.
  final int value;

  /// Create a new [Flag].
  const Flag(this.value);

  /// Create a new [Flag] from an offset into the bitfield.
  const Flag.fromOffset(int offset) : value = 1 << offset;
}
