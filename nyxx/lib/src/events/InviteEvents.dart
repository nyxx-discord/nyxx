part of nyxx;

/// Emitted when invite is creating
class InviteCreatedEvent {
  late final Invite invite;
  
  InviteCreatedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.invite = Invite._new(raw['d'] as Map<String, dynamic>, client);
  }
}

/// Emitted when invite is deleted
class InviteDeletedEvent {
  /// Channel to which invite was pointing
  Channel? channel;

  /// Guild where invite was deleted
  Guild? guild;

  /// Id of channel to which invite was pointing
  late final Snowflake channelId;

  /// ID of guild where invite was deleted
  late final Snowflake guildId;

  /// Code of invite
  late final String code;

  InviteDeletedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.code = raw['d']['code'] as String;
    this.channel = client.channels[Snowflake(raw['d']['channel_id'])];

    if(raw['d']['guild_id'] != null) {
      this.guild = client.guilds[Snowflake(raw['d']['guild_id'])];
    }
  }
}