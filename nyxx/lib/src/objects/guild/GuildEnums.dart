part of nyxx;

class PremiumTier {
  static const PremiumTier dnd = const PremiumTier._create(0);
  static const PremiumTier offline = const PremiumTier._create(1);
  static const PremiumTier online = const PremiumTier._create(2);
  static const PremiumTier idle = const PremiumTier._create(3);

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