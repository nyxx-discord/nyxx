import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

abstract class IGuildWelcomeScreen {
  /// The server description shown in the welcome screen.
  String? get description;

  /// The channels shown in the welcome screen.
  /// Up to 5 channels.
  List<IWelcomeChannel> get channels;
}

class GuildWelcomeScreen implements IGuildWelcomeScreen {
  /// The server description shown in the welcome screen.
  @override
  late final String? description;

  /// The channels shown in the welcome screen.
  /// Up to 5 channels.
  @override
  late final List<IWelcomeChannel> channels;

  /// Creates an instance of [GuildWelcomeScreen]
  GuildWelcomeScreen(RawApiMap raw, INyxx client) {
    description = raw["description"] as String?;
    channels = [for (final rawChannel in raw["welcome_channels"]) WelcomeChannel(rawChannel as RawApiMap, client)];
  }
}

abstract class IWelcomeChannel {
  /// The channel id.
  Cacheable<Snowflake, IChannel> get channel;

  /// The description shown for the channel.
  String? get description;

  /// The emoji id if [emojiName] is a custom emoji.
  Snowflake? get emojiId;

  /// The name of the emoji if custom, otherwise the unicode character.
  /// Or `null` if no emoji is set.
  String? get emojiName;

  /// The emoji in the channel.
  /// This can be a [UnicodeEmoji] or a [IResolvableGuildEmojiPartial]
  IEmoji? get emoji;
}

class WelcomeChannel implements IWelcomeChannel {
  /// The channel id.
  @override
  late final Cacheable<Snowflake, IChannel> channel;

  /// The description shown for the channel.
  @override
  late final String? description;

  /// The emoji id if [emojiName] is a custom emoji.
  @override
  late final Snowflake? emojiId;

  /// The name of the emoji if custom, otherwise the unicode character.
  /// Or `null` if no emoji is set.
  @override
  late final String? emojiName;

  /// The emoji in the channel.
  /// This can be a [UnicodeEmoji] or a [IResolvableGuildEmojiPartial]
  @override
  late final IEmoji? emoji;

  /// Creates an instance of [WelcomeChannel]
  WelcomeChannel(RawApiMap raw, INyxx client) {
    channel = ChannelCacheable(client, Snowflake(raw["channel_id"]));
    description = raw["description"] as String?;
    emojiName = raw["emoji_name"] as String?;

    if (raw['emoji_id'] != null) {
      emojiId = Snowflake(raw['emoji_id']);
      // Used because ResolvableEmoji takes a map and not a sole id
      final emojiMap = {
        'id': emojiId,
      };
      emoji = ResolvableGuildEmojiPartial(emojiMap, client);
    } else {
      emoji = UnicodeEmoji(emojiName!);
    }
  }
}