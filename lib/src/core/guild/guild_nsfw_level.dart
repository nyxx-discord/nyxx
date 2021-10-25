import 'package:nyxx/src/utils/enum.dart';

class GuildNsfwLevel extends IEnum<int> {
  static const GuildNsfwLevel def = GuildNsfwLevel._create(0);
  static const GuildNsfwLevel explicit = GuildNsfwLevel._create(1);
  static const GuildNsfwLevel safe = GuildNsfwLevel._create(2);
  static const GuildNsfwLevel ageRestricted = GuildNsfwLevel._create(3);

  const GuildNsfwLevel._create(int value) : super(value);

  /// Create [StageChannelInstancePrivacyLevel] from [value]
  GuildNsfwLevel.from(int value) : super(value);
}
