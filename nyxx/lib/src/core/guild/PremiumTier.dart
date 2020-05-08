part of nyxx;

/// Boost level of guild
class PremiumTier extends IEnum<int> {
  static const PremiumTier none = const PremiumTier._create(0);
  static const PremiumTier tier1 = const PremiumTier._create(1);
  static const PremiumTier tier2 = const PremiumTier._create(2);
  static const PremiumTier tier3 = const PremiumTier._create(3);

  const PremiumTier._create(int? value) : super(value ?? 0);
  PremiumTier.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == _value;
    }

    return super == other;
  }
}
