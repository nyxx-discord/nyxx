import 'package:nyxx/nyxx.dart';

class ExplicitContentFilterLevel extends IEnum<int> {
  /// Media content will not be scanned.
  static const ExplicitContentFilterLevel disabled = ExplicitContentFilterLevel._create(0);

  /// Media content sent by members without roles will be scanned.
  static const ExplicitContentFilterLevel membersWithoutRoles = ExplicitContentFilterLevel._create(1);

  /// Media content sent by all members will be scanned.
  static const ExplicitContentFilterLevel everyone = ExplicitContentFilterLevel._create(2);

  /// Creates new instance from given [value].
  ExplicitContentFilterLevel.from(int? value) : super(value ?? 0);
  const ExplicitContentFilterLevel._create(int? value) : super(value ?? 0);

  @override
  bool operator ==(dynamic other) {
    if (other is ExplicitContentFilterLevel) {
      return other.value == other;
    }

    if (other is int) {
      return other == value;
    }

    return false;
  }

  @override
  int get hashCode => value.hashCode;
}
