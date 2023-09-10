import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template channel_mention}
/// A channel mentioned in a [Message].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#channel-mention-object
/// {@endtemplate}
class ChannelMention extends PartialChannel {
  /// The ID of the [Guild] containing the mentioned channel.
  final Snowflake guildId;

  /// The type of channel mentioned.
  final ChannelType type;

  /// The name of the mentioned channel.
  final String name;

  /// {@macro channel_mention}
  ChannelMention({
    required super.id,
    required super.manager,
    required this.guildId,
    required this.type,
    required this.name,
  });

  /// The guild containing the mentioned channel.
  PartialGuild get guild => manager.client.guilds[guildId];
}
