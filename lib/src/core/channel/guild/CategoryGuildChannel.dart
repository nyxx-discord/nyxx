import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/channel/guild/GuildChannel.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class ICategoryGuildChannel implements IGuildChannel {

}

class CategoryGuildChannel extends GuildChannel implements ICategoryGuildChannel {
  CategoryGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]): super(client, raw, guildId);
}
