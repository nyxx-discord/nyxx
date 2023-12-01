import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/channel/guild_channel.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/role.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class GuildBuilder extends CreateBuilder<Guild> {
  String name;

  ImageBuilder? icon;

  VerificationLevel? verificationLevel;

  MessageNotificationLevel? defaultMessageNotificationLevel;

  ExplicitContentFilterLevel? explicitContentFilterLevel;

  List<RoleBuilder>? roles;

  List<GuildChannelBuilder>? channels;

  Snowflake? afkChannelId;

  Duration? afkTimeout;

  Snowflake? systemChannelId;

  Flags<SystemChannelFlags>? systemChannelFlags;

  GuildBuilder({
    required this.name,
    this.icon,
    this.verificationLevel,
    this.defaultMessageNotificationLevel,
    this.explicitContentFilterLevel,
    this.roles,
    this.channels,
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
        if (roles != null) 'roles': roles!.map((b) => b.build()).toList(),
        if (channels != null) 'channels': channels!.map((b) => b.build()).toList(),
        if (afkChannelId != null) 'afk_channel_id': afkChannelId!.toString(),
        if (afkTimeout != null) 'afk_timeout': afkTimeout!.inSeconds,
        if (systemChannelId != null) 'system_channel_id': systemChannelId!.toString(),
        if (systemChannelFlags != null) 'system_channel_flags': systemChannelFlags!.value,
      };
}

class GuildUpdateBuilder extends UpdateBuilder<Guild> {
  String? name;

  VerificationLevel? verificationLevel;

  MessageNotificationLevel? defaultMessageNotificationLevel;

  ExplicitContentFilterLevel? explicitContentFilterLevel;

  Snowflake? afkChannelId;

  Duration? afkTimeout;

  ImageBuilder? icon;

  Snowflake? newOwnerId;

  ImageBuilder? splash;

  ImageBuilder? discoverySplash;

  ImageBuilder? banner;

  Snowflake? systemChannelId;

  Flags<SystemChannelFlags>? systemChannelFlags;

  Snowflake? rulesChannelId;

  Snowflake? publicUpdatesChannelId;

  Locale? preferredLocale;

  Flags<GuildFeatures>? features;

  String? description;

  bool? premiumProgressBarEnabled;

  Snowflake? safetyAlertsChannelId;

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
    this.safetyAlertsChannelId,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (verificationLevel != null) 'verification_level': verificationLevel!.value,
        if (defaultMessageNotificationLevel != null) 'default_message_notification_level': defaultMessageNotificationLevel!.value,
        if (explicitContentFilterLevel != null) 'explicit_content_filter_level': explicitContentFilterLevel!.value,
        if (!identical(afkChannelId, sentinelSnowflake)) 'afk_channel_id': afkChannelId?.toString(),
        if (afkTimeout != null) 'afk_timeout': afkTimeout!.inSeconds,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (newOwnerId != null) 'owner_id': newOwnerId!.toString(),
        if (!identical(splash, sentinelImageBuilder)) 'splash': splash?.buildDataString(),
        if (!identical(discoverySplash, sentinelImageBuilder)) 'discoverySplash': discoverySplash?.buildDataString(),
        if (!identical(banner, sentinelImageBuilder)) 'banner': banner?.buildDataString(),
        if (systemChannelId != null) 'system_channel_id': systemChannelId!.toString(),
        if (systemChannelFlags != null) 'system_channel_flags': systemChannelFlags!.value,
        if (rulesChannelId != null) 'rules_channel_id': rulesChannelId!.toString(),
        if (publicUpdatesChannelId != null) 'public_updates_channel_id': publicUpdatesChannelId!.toString(),
        if (preferredLocale != null) 'preferred_locale': preferredLocale!.identifier,
        if (features != null) 'features': GuildManager.serializeGuildFeatures(features!),
        if (!identical(description, sentinelString)) 'description': description,
        if (premiumProgressBarEnabled != null) 'premium_progress_bar_enabled': premiumProgressBarEnabled,
        if (safetyAlertsChannelId != null) 'safety_alerts_channel_id': safetyAlertsChannelId! == Snowflake.zero ? null : safefyAlertsChannel!.toString(),
      };
}
