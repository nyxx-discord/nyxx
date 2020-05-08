part of nyxx;

///Premium types denote the level of premium a user has.
class NitroType extends IEnum<int> {
  static const NitroType none = const NitroType._create(0);
  static const NitroType classic = const NitroType._create(1);
  static const NitroType nitro = const NitroType._create(2);

  const NitroType._create(int? value) : super(value ?? 0);
  NitroType.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == _value;
    }

    return super == other;
  }
}
