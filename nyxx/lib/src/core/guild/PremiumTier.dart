part of nyxx;

/// Boost level of guild
class PremiumTier {
  static const PremiumTier none = const PremiumTier._create(0);
  static const PremiumTier tier1 = const PremiumTier._create(1);
  static const PremiumTier tier2 = const PremiumTier._create(2);
  static const PremiumTier tier3 = const PremiumTier._create(3);

  final int _value;

  const PremiumTier._create(int? value) : _value = value ?? 0;
  PremiumTier.from(int? value) : _value = value ?? 0;

  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) {
    if (other is PremiumTier || other is int)
      return other == _value;

    return false;
  }
}