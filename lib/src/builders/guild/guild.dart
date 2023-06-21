import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class GuildBuilder extends CreateBuilder<Guild> {
  final String name;

  final ImageBuilder? icon;

  final VerificationLevel? verificationLevel;

  final MessageNotificationLevel? defaultMessageNotificationLevel;

  final ExplicitContentFilterLevel? explicitContentFilterLevel;

  // TODO
  //final List<Role> roles;

  // TODO
  //final List<GuildChannel> channels;

  final Snowflake? afkChannelId;

  final Duration? afkTimeout;

  final Snowflake? systemChannelId;

  final Flags<SystemChannelFlags>? systemChannelFlags;

  GuildBuilder({
    required this.name,
    this.icon,
    this.verificationLevel,
    this.defaultMessageNotificationLevel,
    this.explicitContentFilterLevel,
    this.afkChannelId,
    this.afkTimeout,
    this.systemChannelId,
    this.systemChannelFlags,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (icon != null) 'icon': icon!.buildDataString(),
        if (verificationLevel != null) 'verification_level': verificationLevel!.value,
        if (defaultMessageNotificationLevel != null) 'default_message_notification_level': defaultMessageNotificationLevel!.value,
        if (explicitContentFilterLevel != null) 'explicit_content_filter_level': explicitContentFilterLevel!.value,
        if (afkChannelId != null) 'afk_channel_id': afkChannelId!.toString(),
        if (afkTimeout != null) 'afk_timeout': afkTimeout!.inSeconds,
        if (systemChannelId != null) 'system_channel_id': systemChannelId!.toString(),
        if (systemChannelFlags != null) 'system_channel_flags': systemChannelFlags!.value,
      };
}

class GuildUpdateBuilder extends UpdateBuilder<Guild> {
  final String? name;

  final VerificationLevel? verificationLevel;

  final MessageNotificationLevel? defaultMessageNotificationLevel;

  final ExplicitContentFilterLevel? explicitContentFilterLevel;

  final Snowflake? afkChannelId;

  final Duration? afkTimeout;

  final ImageBuilder? icon;

  final Snowflake? newOwnerId;

  final ImageBuilder? splash;

  final ImageBuilder? discoverySplash;

  final ImageBuilder? banner;

  final Snowflake? systemChannelId;

  final Flags<SystemChannelFlags>? systemChannelFlags;

  final Snowflake? rulesChannelId;

  final Snowflake? publicUpdatesChannelId;

  final Locale? preferredLocale;

  final Flags<GuildFeatures>? features;

  final String? description;

  final bool? premiumProgressBarEnabled;

  GuildUpdateBuilder({
    this.name,
    this.verificationLevel,
    this.defaultMessageNotificationLevel,
    this.explicitContentFilterLevel,
    this.afkChannelId = sentinelSnowflake,
    this.afkTimeout,
    this.icon = sentinelImageBuilder,
    this.newOwnerId,
    this.splash = sentinelImageBuilder,
    this.discoverySplash = sentinelImageBuilder,
    this.banner = sentinelImageBuilder,
    this.systemChannelId,
    this.systemChannelFlags,
    this.rulesChannelId,
    this.publicUpdatesChannelId,
    this.preferredLocale,
    this.features,
    this.description = sentinelString,
    this.premiumProgressBarEnabled,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (verificationLevel != null) 'verificationLevel': verificationLevel!.value,
        if (defaultMessageNotificationLevel != null) 'defaultMessageNotificationLevel': defaultMessageNotificationLevel!.value,
        if (explicitContentFilterLevel != null) 'explicitContentFilterLevel': explicitContentFilterLevel!.value,
        if (!identical(afkChannelId, sentinelSnowflake)) 'afkChannelId': afkChannelId?.toString(),
        if (afkTimeout != null) 'afkTimeout': afkTimeout!.inSeconds,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (newOwnerId != null) 'newOwnerId': newOwnerId!.toString(),
        if (!identical(splash, sentinelImageBuilder)) 'splash': splash?.buildDataString(),
        if (!identical(discoverySplash, sentinelImageBuilder)) 'discoverySplash': discoverySplash?.buildDataString(),
        if (!identical(banner, sentinelImageBuilder)) 'banner': banner?.buildDataString(),
        if (systemChannelId != null) 'systemChannelId': systemChannelId!.toString(),
        if (systemChannelFlags != null) 'systemChannelFlags': systemChannelFlags!.value,
        if (rulesChannelId != null) 'rulesChannelId': rulesChannelId!.toString(),
        if (publicUpdatesChannelId != null) 'publicUpdatesChannelId': publicUpdatesChannelId!.toString(),
        if (preferredLocale != null) 'preferredLocale': preferredLocale!.identifier,
        if (features != null) 'features': GuildManager.serializeGuildFeatures(features!),
        if (!identical(description, sentinelString)) 'description': description,
        if (premiumProgressBarEnabled != null) 'premiumProgressBarEnabled': premiumProgressBarEnabled,
      };
}
