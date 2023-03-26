import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ChannelMention extends PartialChannel {
  final Snowflake guildId;

  final ChannelType type;

  final String name;

  ChannelMention({
    required super.id,
    required super.manager,
    required this.guildId,
    required this.type,
    required this.name,
  });
}
