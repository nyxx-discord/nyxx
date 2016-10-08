part of discord;

/// An invite.
class Invite {
  /// The client.
  Client client;

  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  InviteGuild guild;

  /// A mini channel object for the invite's channel.
  InviteChannel channel;

  /// Constructs a new [Invite].
  Invite(this.client, Map<String, dynamic> data) {
    this.code = data['code'];
    this.guild =
        new InviteGuild(this.client, data['guild'] as Map<String, dynamic>);
    this.channel =
        new InviteChannel(this.client, data['channel'] as Map<String, dynamic>);
  }
}
