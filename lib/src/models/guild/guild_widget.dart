import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class GuildWidget with ToStringHelper {
  final Snowflake guildId;

  final String name;

  final String? invite;

  final List<PartialChannel> channels;

  final List<PartialUser> users;

  final int presenceCount;

  GuildWidget({
    required this.guildId,
    required this.name,
    required this.invite,
    required this.channels,
    required this.users,
    required this.presenceCount,
  });
}

class WidgetSettings with ToStringHelper {
  final bool isEnabled;

  final Snowflake? channelId;

  WidgetSettings({
    required this.isEnabled,
    required this.channelId,
  });
}

enum WidgetImageStyle {
  sheild._('shield'),
  banner1._('banner1'),
  banner2._('banner2'),
  banner3._('banner3'),
  banner4._('banner4');

  final String value;

  const WidgetImageStyle._(this.value);

  @override
  String toString() => 'WidgetImageStyle($value)';
}
