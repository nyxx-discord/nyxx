part of nyxx;

/// Represents invite to guild.
class Invite {
  /// The invite's code.
  late final String code;

  /// A mini guild object for the invite's guild.
  late final Guild? guild;

  /// A mini channel object for the invite's channel.
  late final Channel? channel;

  /// Returns url invite
  String get url => "https://discord.gg/$code";

  /// User who created this invite
  late final User? inviter;

  /// The target user for this invite
  late final User? targetUser;

  /// Reference to bot instance
  Nyxx client;

  Invite._new(Map<String, dynamic> raw, this.client) {
    this.code = raw["code"] as String;

    if (raw["guild"] != null) {
      this.guild = client.guilds[Snowflake(raw["guild"]["id"])];
    }

    // TODO: NNBD
    if (raw["channel"] != null) {
      this.channel = client.channels[Snowflake(raw["channel"]["id"])];
    }

    if (raw["channel_id"] != null) {
      this.channel = client.channels[Snowflake(raw["channel_id"])];
    }

    if (raw["inviter"] != null) {
      this.inviter = client.users[Snowflake(raw["inviter"]["id"])];
    }
    
    if (raw["target_user"] != null) {
      this.targetUser = client.users[Snowflake(raw["target_user"]["id"])];
    }
  }

  /// Deletes this Invite.
  Future<void> delete({String? auditReason}) async =>
    client._http._execute(BasicRequest._new("/invites/$code", method: "DELETE", auditLog: auditReason));
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
