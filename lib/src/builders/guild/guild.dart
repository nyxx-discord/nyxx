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
  /// {@template guild_name}
  /// The name of the guild. (2-100 characters)
  /// {@endtemplate}
  String name;

  /// {@template guild_icon}
  /// The icon of the guild.
  /// {@endtemplate}
  ImageBuilder? icon;

  /// {@template guild_verification_level}
  /// The verification level of the guild.
  /// {@endtemplate}
  VerificationLevel? verificationLevel;

  /// {@template guild_default_message_notification_level}
  /// The default message notification level of the guild.
  /// {@endtemplate}
  MessageNotificationLevel? defaultMessageNotificationLevel;

  /// {@template explicit_content_filter_level}
  /// The explicit content filter level of the guild.
  /// {@endtemplate}
  ExplicitContentFilterLevel? explicitContentFilterLevel;

  /// The default roles of the guild.
  List<RoleBuilder>? roles;

  /// The default channels of the guild.
  List<GuildChannelBuilder>? channels;

  /// {@template afk_channel_id}
  /// The id of the afk channel.
  /// {@endtemplate}
  // TODO: Add an `id` field on ChannelBuilder.
  Snowflake? afkChannelId;

  /// {@template afk_timeout}
  /// The afk timeout of the guild.
  /// {@endtemplate}
  Duration? afkTimeout;

  /// {@template system_channel_id}
  /// The id of the channel where guild notices such as welcome messages and boost events are posted.
  /// {@endtemplate}
  // TODO: Same as above.
  Snowflake? systemChannelId;

  /// {@template system_channel_flags}
  /// The default system channel flags.
  /// {@endtemplate}
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
        if (defaultMessageNotificationLevel != null) 'default_message_notifications': defaultMessageNotificationLevel!.value,
        if (explicitContentFilterLevel != null) 'explicit_content_filter': explicitContentFilterLevel!.value,
        if (roles != null) 'roles': roles!.map((b) => b.build()).toList(),
        if (channels != null) 'channels': channels!.map((b) => b.build()).toList(),
        if (afkChannelId != null) 'afk_channel_id': afkChannelId!.toString(),
        if (afkTimeout != null) 'afk_timeout': afkTimeout!.inSeconds,
        if (systemChannelId != null) 'system_channel_id': systemChannelId!.toString(),
        if (systemChannelFlags != null) 'system_channel_flags': systemChannelFlags!.value,
      };
}

class GuildUpdateBuilder extends UpdateBuilder<Guild> {
  /// {@macro guild_name}
  String? name;

  /// {@macro guild_verification_level}
  VerificationLevel? verificationLevel;

  /// {@macro guild_default_message_notification_level}
  MessageNotificationLevel? defaultMessageNotificationLevel;

  /// {@macro explicit_content_filter_level}
  ExplicitContentFilterLevel? explicitContentFilterLevel;

  /// {@macro afk_channel_id}
  Snowflake? afkChannelId;

  /// {@macro afk_timeout}
  Duration? afkTimeout;

  /// {@macro guild_icon}
  ImageBuilder? icon;

  /// The id of the new owner of the guild.
  Snowflake? newOwnerId;

  /// The splash of the guild.
  ImageBuilder? splash;

  /// The discovery splash of the guild.
  ImageBuilder? discoverySplash;

  /// The banner of the guild.
  ImageBuilder? banner;

  /// {@macro system_channel_id}
  Snowflake? systemChannelId;

  /// {@macro system_channel_flags}
  Flags<SystemChannelFlags>? systemChannelFlags;

  /// The id of the rules channel.
  Snowflake? rulesChannelId;

  /// The id of the public updates channel. 
  Snowflake? publicUpdatesChannelId;

  /// The preferred locale of the guild.
  Locale? preferredLocale;

  /// The features of the guild.
  Flags<GuildFeatures>? features;

  /// The description of the guild.
  String? description;

  /// Whether the premium progress bar is enabled.
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
    this.systemChannelId = sentinelSnowflake,
    this.systemChannelFlags,
    this.rulesChannelId = sentinelSnowflake,
    this.publicUpdatesChannelId = sentinelSnowflake,
    this.preferredLocale,
    this.features,
    this.description = sentinelString,
    this.premiumProgressBarEnabled,
    this.safetyAlertsChannelId = sentinelSnowflake,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (verificationLevel != null) 'verification_level': verificationLevel!.value,
        if (defaultMessageNotificationLevel != null) 'default_message_notifications': defaultMessageNotificationLevel!.value,
        if (explicitContentFilterLevel != null) 'explicit_content_filter': explicitContentFilterLevel!.value,
        if (!identical(afkChannelId, sentinelSnowflake)) 'afk_channel_id': afkChannelId?.toString(),
        if (afkTimeout != null) 'afk_timeout': afkTimeout!.inSeconds,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (newOwnerId != null) 'owner_id': newOwnerId!.toString(),
        if (!identical(splash, sentinelImageBuilder)) 'splash': splash?.buildDataString(),
        if (!identical(discoverySplash, sentinelImageBuilder)) 'discovery_splash': discoverySplash?.buildDataString(),
        if (!identical(banner, sentinelImageBuilder)) 'banner': banner?.buildDataString(),
        if (!identical(systemChannelId, sentinelSnowflake)) 'system_channel_id': systemChannelId?.toString(),
        if (systemChannelFlags != null) 'system_channel_flags': systemChannelFlags!.value,
        if (!identical(rulesChannelId, sentinelSnowflake)) 'rules_channel_id': rulesChannelId?.toString(),
        if (!identical(publicUpdatesChannelId, sentinelSnowflake)) 'public_updates_channel_id': publicUpdatesChannelId?.toString(),
        if (preferredLocale != null) 'preferred_locale': preferredLocale!.identifier,
        if (features != null) 'features': GuildManager.serializeGuildFeatures(features!),
        if (!identical(description, sentinelString)) 'description': description,
        if (premiumProgressBarEnabled != null) 'premium_progress_bar_enabled': premiumProgressBarEnabled,
        if (!identical(safetyAlertsChannelId, sentinelSnowflake)) 'safety_alerts_channel_id': safetyAlertsChannelId?.toString(),
      };
}
