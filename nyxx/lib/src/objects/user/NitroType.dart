part of nyxx;

///Premium types denote the level of premium a user has.
class NitroType {
  static const NitroType none = const NitroType._create(0);
  static const NitroType classic = const NitroType._create(1);
  static const NitroType nitro = const NitroType._create(2);

  final int _value;

  const NitroType._create(int? value) : _value = value ?? 0;
  NitroType.from(int? value) : _value = value ?? 0;

  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) {
    if (other is NitroType || other is int)
      return other == _value;

    return false;
  }
}