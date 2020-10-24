part of nyxx;

/// Represents invite to guild.
class Invite {
  /// The invite's code.
  late final String code;

  /// A mini guild object for the invite's guild.
  late final Cacheable<Snowflake, Guild>? guild;

  /// A mini channel object for the invite's channel.
  late final Cacheable<Snowflake, TextChannel>? channel;

  /// User who created this invite
  late final User? inviter;

  /// The target user for this invite
  late final Cacheable<Snowflake, User>? targetUser;

  /// Reference to bot instance
  final Nyxx client;

  /// Returns url to invite
  String get url => "https://discord.gg/$code";

  Invite._new(Map<String, dynamic> raw, this.client) {
    this.code = raw["code"] as String;

    if (raw["guild"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["guild"]["id"]));
    } else {
      this.guild = null;
    }

    if (raw["channel"] != null) {
      this.channel = _ChannelCacheable(client, Snowflake(raw["channel"]["id"]));
    } else {
      this.channel = null;
    }

    if (raw["inviter"] != null) {
      this.inviter = User._new(client, raw["inviter"] as Map<String, dynamic>);
    } else {
      this.inviter = null;
    }
    
    if (raw["target_user"] != null) {
      this.targetUser = _UserCacheable(client, Snowflake(raw["target_user"]["id"]));
    } else {
      this.targetUser = null;
    }
  }

  /// Deletes this [Invite].
  Future<void> delete({String? auditReason}) async =>
    client._httpEndpoints.deleteInvite(this.code, auditReason: auditReason);
}

/// Invite object with additional metadata
class InviteWithMeta extends Invite {
  /// Date when invite was created
  late final DateTime createdAt;

  /// Whether this invite only grants temporary membership
  late final bool temporary;

  /// Number of uses of this invite
  late final int uses;

  /// Max number of uses of this invite
  late final int maxUses;

  /// Duration (in seconds) after which the invite expires
  late final int maxAge;

  /// Date when invite will expire
  DateTime get expiryDate =>
    this.createdAt.add(Duration(seconds: maxAge));

  /// True if Invite is valid and can be used
  bool get isValid {
    var ageValidity = true;
    var expiryValidity = true;

    if (this.maxUses > 0) {
      ageValidity = this.uses <= this.maxUses;
    }

    if (this.maxAge > 0) {
      expiryValidity = expiryDate.isAfter(DateTime.now());
    }

    return ageValidity && expiryValidity;
  }

  InviteWithMeta._new(Map<String, dynamic> raw, Nyxx client) : super._new(raw, client) {
    this.createdAt = DateTime.parse(raw["created_at"] as String);
    this.temporary = raw["temporary"] as bool;
    this.uses = raw["uses"] as int;
    this.maxUses = raw["max_uses"] as int;
    this.maxAge = raw["max_age"] as int;
  }
}
