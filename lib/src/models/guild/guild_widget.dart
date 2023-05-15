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
