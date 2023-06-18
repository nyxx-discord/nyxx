import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template guild_widget}
/// A [Guild]'s widget.
/// {@endtemplate}
class GuildWidget with ToStringHelper {
  /// The ID of the guild this widget is for.
  final Snowflake guildId;

  // The name of the guild.
  final String name;

  /// An invite URL to the guild.
  final String? invite;

  /// A list of channels in the guild.
  final List<PartialChannel> channels;

  /// A list of users in the guild.
  final List<PartialUser> users;

  /// The number of presences in the guild.
  final int presenceCount;

  /// {@macro guild_widget}
  GuildWidget({
    required this.guildId,
    required this.name,
    required this.invite,
    required this.channels,
    required this.users,
    required this.presenceCount,
  });
}

/// {@template widget_settings}
/// The settings for a [Guild]'s widget.
/// {@endtemplate}
class WidgetSettings with ToStringHelper {
  /// Whether the widget is enabled in this guild.
  final bool isEnabled;

  /// The ID of the channel the widget should send users to.
  final Snowflake? channelId;

  /// {@macro widget_settings}
  WidgetSettings({
    required this.isEnabled,
    required this.channelId,
  });
}

/// The style of a guild widget image.
enum WidgetImageStyle {
  sheild._('shield'),
  banner1._('banner1'),
  banner2._('banner2'),
  banner3._('banner3'),
  banner4._('banner4');

  /// The value of this style.
  final String value;

  const WidgetImageStyle._(this.value);

  @override
  String toString() => 'WidgetImageStyle($value)';
}
