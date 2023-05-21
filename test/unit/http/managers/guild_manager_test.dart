import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleGuild = {
  "id": "197038439483310086",
  "name": "Discord Testers",
  "icon": "f64c482b807da4f539cff778d174971c",
  "description": "The official place to report Discord Bugs!",
  "splash": null,
  "discovery_splash": null,
  "features": [
    "ANIMATED_ICON",
    "VERIFIED",
    "NEWS",
    "VANITY_URL",
    "DISCOVERABLE",
    // "MORE_EMOJI", // This feature is in the sample guild but is undocumented
    "INVITE_SPLASH",
    "BANNER",
    "COMMUNITY",
  ],
  "emojis": [],
  "banner": "9b6439a7de04f1d26af92f84ac9e1e4a",
  "owner_id": "73193882359173120",
  "application_id": null,
  "region": null,
  "afk_channel_id": null,
  "afk_timeout": 300,
  "system_channel_id": null,
  "widget_enabled": true,
  "widget_channel_id": null,
  "verification_level": 3,
  "roles": [],
  "default_message_notifications": 1,
  "mfa_level": 1,
  "explicit_content_filter": 2,
  "max_presences": 40000,
  "max_members": 250000,
  "vanity_url_code": "discord-testers",
  "premium_tier": 3,
  "premium_subscription_count": 33,
  "system_channel_flags": 0,
  "preferred_locale": "en-US",
  "rules_channel_id": "441688182833020939",
  "public_updates_channel_id": "281283303326089216",

  // These fields are documented as always present, but are missing from the provided sample
  "nsfw_level": 2,
  "premium_progress_bar_enabled": true,
};

void checkGuild(Guild guild) {
  expect(guild.id, equals(Snowflake(197038439483310086)));
  expect(guild.name, equals('Discord Testers'));
  expect(guild.iconHash, equals('f64c482b807da4f539cff778d174971c'));
  expect(guild.splashHash, isNull);
  expect(guild.discoverySplashHash, isNull);
  expect(guild.isOwnedByCurrentUser, isNull);
  expect(guild.ownerId, equals(Snowflake(73193882359173120)));
  expect(guild.currentUserPermissions, isNull);
  expect(guild.afkChannelId, isNull);
  expect(guild.afkTimeout, equals(Duration(seconds: 300)));
  expect(guild.isWidgetEnabled, isTrue);
  expect(guild.widgetChannelId, isNull);
  expect(guild.verificationLevel, equals(VerificationLevel.high));
  expect(guild.defaultMessageNotificationLevel, equals(MessageNotificationLevel.onlyMentions));
  expect(guild.explicitContentFilterLevel, equals(ExplicitContentFilterLevel.allMembers));
  expect(
    guild.features,
    equals(
      GuildFeatures.animatedIcon |
          GuildFeatures.verified |
          GuildFeatures.news |
          GuildFeatures.vanityUrl |
          GuildFeatures.discoverable |
          // GuildFeatures.moreEmoji |
          GuildFeatures.inviteSplash |
          GuildFeatures.banner |
          GuildFeatures.community,
    ),
  );
  expect(guild.mfaLevel, equals(MfaLevel.elevated));
  expect(guild.applicationId, isNull);
  expect(guild.systemChannelId, isNull);
  expect(guild.systemChannelFlags, equals(SystemChannelFlags(0)));
  expect(guild.rulesChannelId, equals(Snowflake(441688182833020939)));
  expect(guild.maxPresences, equals(40000));
  expect(guild.maxMembers, equals(250000));
  expect(guild.vanityUrlCode, equals('discord-testers'));
  expect(guild.description, equals('The official place to report Discord Bugs!'));
  expect(guild.bannerHash, equals('9b6439a7de04f1d26af92f84ac9e1e4a'));
  expect(guild.premiumTier, equals(PremiumTier.three));
  expect(guild.premiumSubscriptionCount, equals(33));
  expect(guild.preferredLocale, equals(Locale.enUs));
  expect(guild.publicUpdatesChannelId, equals(Snowflake(281283303326089216)));
  expect(guild.maxVideoChannelUsers, isNull);
  expect(guild.maxStageChannelUsers, isNull);
  expect(guild.approximateMemberCount, isNull);
  expect(guild.approximatePresenceCount, isNull);
  expect(guild.welcomeScreen, isNull);
  expect(guild.nsfwLevel, NsfwLevel.safe);
  expect(guild.hasPremiumProgressBarEnabled, isTrue);
}

final sampleGuild2 = {
  "id": "2909267986263572999",
  "name": "Mason's Test Server",
  "icon": "389030ec9db118cb5b85a732333b7c98",
  "description": null,
  "splash": "75610b05a0dd09ec2c3c7df9f6975ea0",
  "discovery_splash": null,
  "approximate_member_count": 2,
  "approximate_presence_count": 2,
  "features": [
    "INVITE_SPLASH",
    "VANITY_URL",
    // "COMMERCE", // This feature is in the sample guild but is undocumented
    "BANNER",
    "NEWS",
    "VERIFIED",
    "VIP_REGIONS",
  ],
  "emojis": [
    {"name": "ultrafastparrot", "roles": [], "id": "393564762228785161", "require_colons": true, "managed": false, "animated": true, "available": true}
  ],
  "banner": "5c3cb8d1bc159937fffe7e641ec96ca7",
  "owner_id": "53908232506183680",
  "application_id": null,
  "region": null,
  "afk_channel_id": null,
  "afk_timeout": 300,
  "system_channel_id": null,
  "widget_enabled": true,
  "widget_channel_id": "639513352485470208",
  "verification_level": 0,
  "roles": [
    {
      "id": "2909267986263572999",
      "name": "@everyone",
      "permissions": "49794752",
      "position": 0,
      "color": 0,
      "hoist": false,
      "managed": false,
      "mentionable": false
    }
  ],
  "default_message_notifications": 1,
  "mfa_level": 0,
  "explicit_content_filter": 0,
  "max_presences": null,
  "max_members": 250000,
  "max_video_channel_users": 25,
  "vanity_url_code": "no",
  "premium_tier": 0,
  "premium_subscription_count": 0,
  "system_channel_flags": 0,
  "preferred_locale": "en-US",
  "rules_channel_id": null,
  "public_updates_channel_id": null,

  // These fields are documented as always present, but are missing from the provided sample
  "nsfw_level": 2,
  "premium_progress_bar_enabled": true,
};

void checkGuild2(Guild guild) {
  expect(guild.id, equals(Snowflake(2909267986263572999)));
  expect(guild.name, equals("Mason's Test Server"));
  expect(guild.iconHash, equals('389030ec9db118cb5b85a732333b7c98'));
  expect(guild.splashHash, '75610b05a0dd09ec2c3c7df9f6975ea0');
  expect(guild.discoverySplashHash, isNull);
  expect(guild.isOwnedByCurrentUser, isNull);
  expect(guild.ownerId, equals(Snowflake(53908232506183680)));
  expect(guild.currentUserPermissions, isNull);
  expect(guild.afkChannelId, isNull);
  expect(guild.afkTimeout, equals(Duration(seconds: 300)));
  expect(guild.isWidgetEnabled, isTrue);
  expect(guild.widgetChannelId, Snowflake(639513352485470208));
  expect(guild.verificationLevel, equals(VerificationLevel.none));
  expect(guild.defaultMessageNotificationLevel, equals(MessageNotificationLevel.onlyMentions));
  expect(guild.explicitContentFilterLevel, equals(ExplicitContentFilterLevel.disabled));
  expect(
    guild.features,
    equals(
      GuildFeatures.inviteSplash |
          GuildFeatures.vanityUrl |
          // GuildFeatures.commerce |
          GuildFeatures.banner |
          GuildFeatures.news |
          GuildFeatures.verified |
          GuildFeatures.vipRegions,
    ),
  );
  expect(guild.mfaLevel, equals(MfaLevel.none));
  expect(guild.applicationId, isNull);
  expect(guild.systemChannelId, isNull);
  expect(guild.systemChannelFlags, equals(SystemChannelFlags(0)));
  expect(guild.rulesChannelId, isNull);
  expect(guild.maxPresences, isNull);
  expect(guild.maxMembers, equals(250000));
  expect(guild.vanityUrlCode, equals('no'));
  expect(guild.description, isNull);
  expect(guild.bannerHash, equals('5c3cb8d1bc159937fffe7e641ec96ca7'));
  expect(guild.premiumTier, equals(PremiumTier.none));
  expect(guild.premiumSubscriptionCount, equals(0));
  expect(guild.preferredLocale, equals(Locale.enUs));
  expect(guild.publicUpdatesChannelId, isNull);
  expect(guild.maxVideoChannelUsers, equals(25));
  expect(guild.maxStageChannelUsers, isNull);
  expect(guild.approximateMemberCount, equals(2));
  expect(guild.approximatePresenceCount, equals(2));
  expect(guild.welcomeScreen, isNull);
  expect(guild.nsfwLevel, NsfwLevel.safe);
  expect(guild.hasPremiumProgressBarEnabled, isTrue);
}

final sampleWelcomeScreen = {
  "description": "Discord Developers is a place to learn about Discord's API, bots, and SDKs and integrations. This is NOT a general Discord support server.",
  "welcome_channels": [
    {"channel_id": "697138785317814292", "description": "Follow for official Discord API updates", "emoji_id": null, "emoji_name": "📡"},
    {"channel_id": "697236247739105340", "description": "Get help with Bot Verifications", "emoji_id": null, "emoji_name": "📸"},
    {"channel_id": "697489244649816084", "description": "Create amazing things with Discord's API", "emoji_id": null, "emoji_name": "🔬"},
    {"channel_id": "613425918748131338", "description": "Integrate Discord into your game", "emoji_id": null, "emoji_name": "🎮"},
    {"channel_id": "646517734150242346", "description": "Find more places to help you on your quest", "emoji_id": null, "emoji_name": "🔦"}
  ]
};

void checkWelcomeScreen(WelcomeScreen screen) {
  expect(
    screen.description,
    equals("Discord Developers is a place to learn about Discord's API, bots, and SDKs and integrations. This is NOT a general Discord support server."),
  );

  expect(screen.channels, hasLength(5));

  expect(screen.channels[0].channelId, equals(Snowflake(697138785317814292)));
  expect(screen.channels[0].description, equals('Follow for official Discord API updates'));
  expect(screen.channels[0].emojiId, isNull);
  expect(screen.channels[0].emojiName, equals('📡'));
}

final sampleGuildPreview = {
  "id": "197038439483310086",
  "name": "Discord Testers",
  "icon": "f64c482b807da4f539cff778d174971c",
  "splash": null,
  "discovery_splash": null,
  "emojis": [],
  "features": [
    "DISCOVERABLE",
    "VANITY_URL",
    "ANIMATED_ICON",
    "INVITE_SPLASH",
    "NEWS",
    "COMMUNITY",
    "BANNER",
    "VERIFIED",
    // "MORE_EMOJI", // This feature is in the sample guild preview but is undocumented
  ],
  "approximate_member_count": 60814,
  "approximate_presence_count": 20034,
  "description": "The official place to report Discord Bugs!",
  "stickers": []
};

void checkGuildPreview(GuildPreview preview) {
  expect(preview.id, equals(Snowflake(197038439483310086)));
  expect(preview.name, equals('Discord Testers'));
  expect(preview.iconHash, equals('f64c482b807da4f539cff778d174971c'));
  expect(preview.splashHash, isNull);
  expect(preview.discoverySplashHash, isNull);
  expect(
    preview.features,
    equals(
      GuildFeatures.discoverable |
          GuildFeatures.vanityUrl |
          GuildFeatures.animatedIcon |
          GuildFeatures.inviteSplash |
          GuildFeatures.news |
          GuildFeatures.community |
          GuildFeatures.banner |
          GuildFeatures.verified,
    ),
  );
  expect(preview.approximateMemberCount, equals(60814));
  expect(preview.approximatePresenceCount, equals(20034));
  expect(preview.description, equals('The official place to report Discord Bugs!'));
}

final sampleWidgetSettings = {"enabled": true, "channel_id": "41771983444115456"};

void checkWidgetSettings(WidgetSettings settings) {
  expect(settings.isEnabled, isTrue);
  expect(settings.channelId, equals(Snowflake(41771983444115456)));
}

final sampleGuildWidget = {
  "id": "290926798626999250",
  "name": "Test Server",
  "instant_invite": "https://discord.com/invite/abcdefg",
  "channels": [
    {"id": "705216630279993882", "name": "elephant", "position": 2},
    {"id": "669583461748992190", "name": "groovy-music", "position": 1}
  ],
  "members": [
    {
      "id": "0",
      "username": "1234",
      "discriminator": "0000",
      "avatar": null,
      "status": "online",
      "avatar_url":
          "https://cdn.discordapp.com/widget-avatars/FfvURgcr3Za92K3JtoCppqnYMppMDc5B-Rll74YrGCU/C-1DyBZPQ6t5q2RuATFuMFgq0_uEMZVzd_6LbGN_uJKvZflobA9diAlTjhf6CAESLLeTuu4dLuHFWOb_PNLteooNfhC4C6k5QgAGuxEOP12tVVVCvX6t64k14PMXZrGTDq8pWZhukP40Wg"
    }
  ],
  "presence_count": 1
};

void checkGuildWidget(GuildWidget widget) {
  expect(widget.guildId, equals(Snowflake(290926798626999250)));
  expect(widget.name, equals('Test Server'));
  expect(widget.invite, equals('https://discord.com/invite/abcdefg'));
  expect(widget.presenceCount, equals(1));

  expect(widget.channels, hasLength(2));

  expect(widget.users, hasLength(1));
}

final sampleBan = {
  "reason": "mentioning b1nzy",
  "user": {"username": "Mason", "discriminator": "9999", "id": "53908099506183680", "avatar": "a_bab14f271d565501444b2ca3be944b25", "public_flags": 131141}
};

void checkBan(Ban ban) {
  expect(ban.reason, equals('mentioning b1nzy'));
  expect(ban.user.id, equals(Snowflake(53908099506183680)));
}

final sampleOnboarding = {
  "guild_id": "960007075288915998",
  "prompts": [
    {
      "id": "1067461047608422473",
      "title": "What do you want to do in this community?",
      "options": [
        {
          "id": "1067461047608422476",
          "title": "Chat with Friends",
          "description": "",
          "emoji": {"id": "1070002302032826408", "name": "chat", "animated": false},
          "role_ids": [],
          "channel_ids": ["962007075288916001"]
        },
        {
          "id": "1070004843541954678",
          "title": "Get Gud",
          "description": "We have excellent teachers!",
          "emoji": {"id": null, "name": "😀", "animated": false},
          "role_ids": ["982014491980083211"],
          "channel_ids": []
        }
      ],
      "single_select": false,
      "required": false,
      "in_onboarding": true,
      "type": 0
    }
  ],
  "default_channel_ids": [
    "998678771706110023",
    "998678693058719784",
    "1070008122577518632",
    "998678764340912138",
    "998678704446263309",
    "998678683592171602",
    "998678699715067986"
  ],
  "enabled": true
};

void checkOnboarding(Onboarding onboarding) {
  expect(onboarding.guildId, equals(Snowflake(960007075288915998)));
  expect(onboarding.isEnabled, isTrue);
  expect(
    onboarding.defaultChannelIds,
    equals([
      Snowflake(998678771706110023),
      Snowflake(998678693058719784),
      Snowflake(1070008122577518632),
      Snowflake(998678764340912138),
      Snowflake(998678704446263309),
      Snowflake(998678683592171602),
      Snowflake(998678699715067986),
    ]),
  );

  expect(onboarding.prompts, hasLength(1));
  final prompt = onboarding.prompts.first;

  expect(prompt.id, equals(Snowflake(1067461047608422473)));
  expect(prompt.title, equals('What do you want to do in this community?'));

  expect(prompt.options, hasLength(2));
  final option = prompt.options.first;

  expect(option.id, equals(Snowflake(1067461047608422476)));
  expect(option.title, equals('Chat with Friends'));
  expect(option.description, equals(''));
  expect(option.roleIds, equals([]));
  expect(option.channelIds, equals([Snowflake(962007075288916001)]));
}

void main() {
  testManager<Guild, GuildManager>(
    'GuildManager',
    (client, config) => GuildManager(client, config, banConfig: const CacheConfig()),
    RegExp(r'/guilds/\d+'),
    '/guilds',
    sampleObject: sampleGuild,
    sampleMatches: checkGuild,
    additionalSampleObjects: [sampleGuild2],
    additionalSampleMatchers: [checkGuild2],
    additionalParsingTests: [
      ParsingTest<GuildManager, WelcomeScreen, Map<String, Object?>>(
        name: 'parseWelcomeScreen',
        source: sampleWelcomeScreen,
        parse: (manager) => manager.parseWelcomeScreen,
        check: checkWelcomeScreen,
      ),
      ParsingTest<GuildManager, GuildPreview, Map<String, Object?>>(
        name: 'parseGuildPreview',
        source: sampleGuildPreview,
        parse: (manager) => manager.parseGuildPreview,
        check: checkGuildPreview,
      ),
      ParsingTest<GuildManager, WidgetSettings, Map<String, Object?>>(
        name: 'parseWidgetSettings',
        source: sampleWidgetSettings,
        parse: (manager) => manager.parseWidgetSettings,
        check: checkWidgetSettings,
      ),
      ParsingTest<GuildManager, GuildWidget, Map<String, Object?>>(
        name: 'parseGuildWidget',
        source: sampleGuildWidget,
        parse: (manager) => manager.parseGuildWidget,
        check: checkGuildWidget,
      ),
      ParsingTest<GuildManager, Ban, Map<String, Object?>>(
        name: 'parseBan',
        source: sampleBan,
        parse: (manager) => manager.parseBan,
        check: checkBan,
      ),
      ParsingTest<GuildManager, Onboarding, Map<String, Object?>>(
        name: 'parseOnboarding',
        source: sampleOnboarding,
        parse: (manager) => manager.parseOnboarding,
        check: checkOnboarding,
      ),
    ],
    additionalEndpointTests: [],
    createBuilder: GuildBuilder(name: 'Test guild'),
    updateBuilder: GuildUpdateBuilder(),
  );
}
