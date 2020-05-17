part of nyxx;

///Premium types denote the level of premium a user has.
class NitroType extends IEnum<int> {
  static const NitroType none = NitroType._create(0);
  static const NitroType classic = NitroType._create(1);
  static const NitroType nitro = NitroType._create(2);

  const NitroType._create(int? value) : super(value ?? 0);

  /// Creates [NitroType] from [value]. [value] is 0 by default.
  NitroType.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == _value;
    }

    return super == other;
  }
}
