import 'package:nyxx/src/utils/IEnum.dart';

/// Boost level of guild
class PremiumTier extends IEnum<int> {
  static const PremiumTier none = PremiumTier._create(0);
  static const PremiumTier tier1 = PremiumTier._create(1);
  static const PremiumTier tier2 = PremiumTier._create(2);
  static const PremiumTier tier3 = PremiumTier._create(3);

  const PremiumTier._create(int? value) : super(value ?? 0);
  PremiumTier.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
}
