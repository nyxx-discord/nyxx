import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template welcome_screen}
/// The configuration for the welcome screen in a guild.
/// {@endtemplate}
class WelcomeScreen with ToStringHelper {
  /// The description shown in this welcome screen.
  final String? description;

  /// A list of channels shown in this welcome screen.
  final List<WelcomeScreenChannel> channels;

  /// {@macro welcome_screen}
  WelcomeScreen({required this.description, required this.channels});
}

/// {@template welcome_screen_channel}
/// A channel shown in a [WelcomeScreen].
/// {@endtemplate}
class WelcomeScreenChannel with ToStringHelper {
  /// The manager for this [WelcomeScreenChannel].
  final GuildManager manager;

  /// The ID of the channel this welcome screen channel represents.
  final Snowflake channelId;

  /// A description for this channel.
  final String description;

  /// The ID of the emoji associated with this channel.
  final Snowflake? emojiId;

  /// The name of the emoji associated with this channel.
  final String? emojiName;

  /// {@macro welcome_screen_channel}
  WelcomeScreenChannel({
    required this.manager,
    required this.channelId,
    required this.description,
    required this.emojiId,
    required this.emojiName,
  });

  /// The channel this welcome screen channel represents.
  PartialChannel get channel => manager.client.channels[channelId];
}
