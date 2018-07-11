part of nyxx;

/// An invite.
class Invite {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  InviteGuild guild;

  /// A mini channel object for the invite's channel.
  InviteChannel channel;

  Invite._new(this.client, this.raw) {
    this.code = raw['code'];
    this.guild =
        new InviteGuild._new(this.client, raw['guild'] as Map<String, dynamic>);
    this.channel = new InviteChannel._new(
        this.client, raw['channel'] as Map<String, dynamic>);
  }

  /// Deletes this Invite.
  Future<Null> delete({String auditReason = ""}) async {
    await this
        .client
        .http
        .send('DELETE', '/invites/$code', reason: auditReason);
    return null;
  }
}
