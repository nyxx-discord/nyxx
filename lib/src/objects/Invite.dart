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

  Invite._new(this.client, Map<String, dynamic> data) {
    this.code = data['code'];
    this.guild = new InviteGuild._new(
        this.client, data['guild'] as Map<String, dynamic>);
    this.channel = new InviteChannel._new(
        this.client, data['channel'] as Map<String, dynamic>);
  }
}
