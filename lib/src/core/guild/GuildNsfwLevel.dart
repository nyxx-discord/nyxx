part of nyxx;

class GuildNsfwLevel extends IEnum {
  static const GuildNsfwLevel def = const GuildNsfwLevel._create(0);
  static const GuildNsfwLevel explicit = const GuildNsfwLevel._create(1);
  static const GuildNsfwLevel safe = const GuildNsfwLevel._create(2);
  static const GuildNsfwLevel ageRestricted = const GuildNsfwLevel._create(3);

  const GuildNsfwLevel._create(value) : super(value);
  /// Create [StageChannelInstancePrivacyLevel] from [value]
  GuildNsfwLevel.from(value) : super(value);
}
