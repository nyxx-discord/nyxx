part of nyxx;

/// An invite.
class Invite {
  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  Guild guild;

  /// A mini channel object for the invite's channel.
  GuildChannel channel;

  /// Returns url invite
  String get url => "https://discord.gg/$code";

  /// Date when invite was created
  DateTime createdAt;

  /// True if invite is temporary
  bool temporary;

  /// Number of uses of this invite
  int uses;

  /// Max number of uses of this invite
  int maxUses;

  /// User who created this invite
  User inviter;

  Invite._new( this.raw) {
    this.code = raw['code'] as String;
    this.guild = client.guilds[Snowflake(raw['guild']['id'] as String)];
    this.channel = client.channels[Snowflake(raw['channel']['id'] as String)]
        as GuildChannel;

    this.createdAt = DateTime.parse(raw['created_at'] as String);
    this.temporary = raw['temporary'] as bool;
    this.uses = raw['uses'] as int;
    this.maxUses = raw['max_uses'] as int;
    this.inviter = client.users[Snowflake(raw['inviter']['id'] as String)];
  }

  /// Deletes this Invite.
  Future<void> delete({String auditReason = ""}) async {
    await _client
        .http
        .send('DELETE', '/invites/$code', reason: auditReason);
  }
}
