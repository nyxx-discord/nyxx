part of nyxx;

/// Guild features
class GuildFeature extends IEnum<String> {
  /// Guild has access to set an invite splash background
  static const GuildFeature inviteSplash = GuildFeature._create("INVITE_SPLASH");

  /// Guild has access to set 384kbps bitrate in voice (previously VIP voice servers)
  static const GuildFeature vipRegions = GuildFeature._create("VIP_REGIONS");

  /// Guild has access to set a vanity URL
  static const GuildFeature vanityUrl = GuildFeature._create("VANITY_URL");

  /// Guild is verified
  static const GuildFeature verified = GuildFeature._create("VERIFIED");

  /// Guild is partnered
  static const GuildFeature partnered = GuildFeature._create("PARTNERED");

  /// Guild has access to use commerce features (i.e. create store channels)
  static const GuildFeature commerce = GuildFeature._create("COMMERCE");

  /// Guild has access to create news channels
  static const GuildFeature news = GuildFeature._create("NEWS");

  /// Guild is able to be discovered in the directory
  static const GuildFeature discoverable = GuildFeature._create("DISCOVERABLE");

  /// Guild has access to set an animated guild icon
  static const GuildFeature animatedIcon = GuildFeature._create("ANIMATED_ICON");

  /// Guild has access to set a guild banner image
  static const GuildFeature banner = GuildFeature._create("BANNER");

  /// Guild cannot be public
  static const GuildFeature publicDisabled = GuildFeature._create("PUBLIC_DISABLED");

  /// Guild has enabled the welcome screen
  static const GuildFeature welcomeScreenEnabled = GuildFeature._create("WELCOME_SCREEN_ENABLED");

  /// Guild has enabled ticketed events
  static const GuildFeature ticketsEventEnabled = GuildFeature._create("TICKETED_EVENTS_ENABLED");

  /// Guild has enabled monetization
  static const GuildFeature monetizationEnabled = GuildFeature._create("MONETIZATION_ENABLED");

  /// Guild has increased custom sticker slots
  static const GuildFeature moreStickers = GuildFeature._create("MORE_STICKERS");

  /// Guild has access to the three day archive time for threads
  static const GuildFeature threeDayThreadArchive = GuildFeature._create("THREE_DAY_THREAD_ARCHIVE");

  /// Guild has access to the seven day archive time for threads
  static const GuildFeature sevenDayThreadArchive = GuildFeature._create("SEVEN_DAY_THREAD_ARCHIVE");

  /// Guild has access to create private threads
  static const GuildFeature privateThreadsEnabled = GuildFeature._create("PRIVATE_THREADS");

	/// Guild is a Student Hub
  static const GuildFeature studentHub = GuildFeature._create("HUB");

  /// Creates instance of [GuildFeature] from [value].
  GuildFeature.from(String? value) : super(value ?? "");
  const GuildFeature._create(String? value) : super(value ?? "");

  @override
  bool operator ==(dynamic other) {
    if (other is String) {
      return other == _value;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
}
