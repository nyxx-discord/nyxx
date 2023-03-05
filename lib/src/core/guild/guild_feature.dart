import 'package:nyxx/src/utils/enum.dart';

/// Guild features
class GuildFeature extends IEnum<String> {
  /// Guild has Auto Moderation
  static const GuildFeature autoModeration = GuildFeature._create("AUTO_MODERATION");

  /// Guild has access to set an animated guild icon
  static const GuildFeature animatedIcon = GuildFeature._create("ANIMATED_ICON");

  /// Guild has access to set an animated guild banner image
  static const GuildFeature animatedBanner = GuildFeature._create('ANIMATED_BANNER');

  /// Guild has access to set a guild banner image
  static const GuildFeature banner = GuildFeature._create("BANNER");

  /// Guild can enable welcome screen, Membership Screening, stage channels and discovery, and receives community updates
  static const GuildFeature community = GuildFeature._create('COMMUNITY');

  /// Guild is able to be discovered in the directory
  static const GuildFeature discoverable = GuildFeature._create("DISCOVERABLE");

  /// Guild is able to be featured in the directory
  static const GuildFeature featurable = GuildFeature._create('FEATURABLE');

  /// Guild has paused invites, preventing new users from joining
  static const GuildFeature invitesDisabled = GuildFeature._create('INVITES_DISABLED');

  /// Guild has access to set an invite splash background
  static const GuildFeature inviteSplash = GuildFeature._create("INVITE_SPLASH");

  /// Guild has enabled [Membership Screening](https://discord.com/developers/docs/resources/guild#membership-screening-object)
  static const GuildFeature memberVerificationGateEnabled = GuildFeature._create('MEMBER_VERIFICATION_GATE_ENABLED');

  /// Guild has enabled monetization
  static const GuildFeature monetizationEnabled = GuildFeature._create("MONETIZATION_ENABLED");

  /// Guild has increased custom sticker slots
  static const GuildFeature moreStickers = GuildFeature._create("MORE_STICKERS");

  /// Guild has access to create news channels
  static const GuildFeature news = GuildFeature._create("NEWS");

  /// Guild is partnered
  static const GuildFeature partnered = GuildFeature._create("PARTNERED");

  /// Guild can be previewed before joining via Membership Screening or the directory
  static const GuildFeature previewEnabled = GuildFeature._create('PREVIEW_ENABLED');

  /// Guild has access to create private threads
  static const GuildFeature privateThreadsEnabled = GuildFeature._create("PRIVATE_THREADS");

  /// Guild is able to set role icons
  static const GuildFeature roleIcons = GuildFeature._create('ROLE_ICONS');

  /// Guild has enabled ticketed events
  static const GuildFeature ticketsEventEnabled = GuildFeature._create("TICKETED_EVENTS_ENABLED");

  /// Guild has access to set a vanity URL
  static const GuildFeature vanityUrl = GuildFeature._create("VANITY_URL");

  /// Guild is verified
  static const GuildFeature verified = GuildFeature._create("VERIFIED");

  /// Guild has access to set 384kbps bitrate in voice (previously VIP voice servers)
  static const GuildFeature vipRegions = GuildFeature._create("VIP_REGIONS");

  /// Guild has enabled the welcome screen
  static const GuildFeature welcomeScreenEnabled = GuildFeature._create("WELCOME_SCREEN_ENABLED");

  /// Guild has access to use commerce features (i.e. create store channels)
  /// Discord no longer offers the ability to purchase a license to sell PC games.
  /// See https://support-dev.discord.com/hc/en-us/articles/6309018858647-Self-serve-Game-Selling-Deprecation for more information
  static const GuildFeature commerce = GuildFeature._create("COMMERCE");

  /// Guild cannot be public - No longer has meaning
  static const GuildFeature publicDisabled = GuildFeature._create("PUBLIC_DISABLED");

  /// Guild is a Student Hub - Was not documented but exists, this can be removed at any time
  static const GuildFeature studentHub = GuildFeature._create("HUB");

  /// Creates instance of [GuildFeature] from [value].
  GuildFeature.from(String? value) : super(value ?? "");
  const GuildFeature._create(String? value) : super(value ?? "");

  @override
  bool operator ==(dynamic other) {
    if (other is String) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}
