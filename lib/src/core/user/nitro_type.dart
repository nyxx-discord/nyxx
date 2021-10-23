import 'package:nyxx/src/utils/enum.dart';

///Premium types denote the level of premium a user has.
class NitroType extends IEnum<int> {
  static const NitroType none = NitroType._create(0);
  static const NitroType classic = NitroType._create(1);
  static const NitroType nitro = NitroType._create(2);

  /// Creates [NitroType] from [value]. [value] is 0 by default.
  NitroType.from(int? value) : super(value ?? 0);
  const NitroType._create(int? value) : super(value ?? 0);

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
