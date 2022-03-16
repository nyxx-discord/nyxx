import 'package:nyxx/nyxx.dart';

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
  GuildWelcomeScreen(RawApiMap raw) {
    description = raw["description"] as String?;
    channels = [for (final rawChannel in raw["channels"]) WelcomeChannel(rawChannel as RawApiMap)];
  }
}

abstract class IWelcomeChannel {
  /// The channel id.
  Snowflake get id;

  /// The description shown for the channel.
  String? get description;

  /// The emoji id if [emojiName] is a custom emoji.
  Snowflake? emojiId;

  /// The name of the emoji if custom, otherwise the unicode character.
  /// Or `null` if no emoji is set.
  String? emojiName;
}

class WelcomeChannel implements IWelcomeChannel {
  /// The channel id.
  @override
  late final Snowflake id;

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

  /// Creates an instance of [WelcomeChannel]
  WelcomeChannel(RawApiMap raw) {
    id = Snowflake(raw["id"]);
    description = raw["description"] as String?;
    emojiId = raw['emoji_id'] != null ? Snowflake(raw['emoji_id']) : null;
    emojiName = raw["emoji_name"] as String?;
  }
}
