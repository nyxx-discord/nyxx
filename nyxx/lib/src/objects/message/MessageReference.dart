part of nyxx;

/// Reference data to cross posted message
class MessageReference {
  /// Original message
  Message? message;

  /// Original channel
  MessageChannel? channel;

  /// Original guild
  Guild? guild;

  MessageReference._new(Map<String, dynamic> raw, Nyxx client) {
    this.channel = client.channels[Snowflake(raw['channel_id'])] as MessageChannel?;

    if(raw['message_id'] != null && this.channel != null) {
      this.message = this.channel!.messages[Snowflake(raw['message_id'])];
    }
    if(raw['guild_id'] != null) {
      this.guild = client.guilds[Snowflake(raw['guild_id'])];
    }
  }
}