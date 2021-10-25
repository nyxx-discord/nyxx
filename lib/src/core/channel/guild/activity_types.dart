import 'package:nyxx/src/utils/enum.dart';

/// Activity Types
class VoiceActivityType extends IEnum<String> {
  static const VoiceActivityType youtubeTogether = VoiceActivityType._create("755600276941176913");
  static const VoiceActivityType poker = VoiceActivityType._create("755827207812677713");
  static const VoiceActivityType betrayal = VoiceActivityType._create("773336526917861400");
  static const VoiceActivityType fishing = VoiceActivityType._create("814288819477020702");
  static const VoiceActivityType chess = VoiceActivityType._create("832012774040141894");
  static const VoiceActivityType letterTile = VoiceActivityType._create("879863686565621790");
  static const VoiceActivityType wordSnack = VoiceActivityType._create("879863976006127627");
  static const VoiceActivityType doodleCrew = VoiceActivityType._create("878067389634314250");

  /// Creates instance of [VoiceActivityType] from [value].
  VoiceActivityType.from(String? value) : super(value ?? "");
  const VoiceActivityType._create(String? value) : super(value ?? "");

  @override
  bool operator ==(dynamic other) {
    if (other is String) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
}
