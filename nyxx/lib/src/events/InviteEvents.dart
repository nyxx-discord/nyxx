part of nyxx;

/// Emitted when invite is creating
class InviteCreatedEvent {
  late final Invite invite;
  
  InviteCreatedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.invite = Invite._new(json['d'] as Map<String, dynamic>, client);
  }
}

/// Emitted when invite is deleted
class InviteDeletedEvent {
  Channel? channel;
  Guild? guild;

  late final String code;

  InviteDeletedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.code = json['d']['code'] as String;
    this.channel = client.channels[Snowflake(json['d']['channel_id'])];

    if(json['d']['guild_id'] != null) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'])];
    }
  }
}