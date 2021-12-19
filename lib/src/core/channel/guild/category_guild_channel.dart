import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class ICategoryGuildChannel implements IGuildChannel {}

class CategoryGuildChannel extends GuildChannel implements ICategoryGuildChannel {
  CategoryGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId);
}
