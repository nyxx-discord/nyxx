part of nyxx;

/// Object of team that manages given app
class AppTeam extends SnowflakeEntity {
  /// Hash of team icon
  late final String? iconHash;

  /// Id of Team owner
  late final Snowflake ownerId;

  /// List of members of team
  late final List<AppTeamMember> members;

  /// Returns instance of [AppTeamMember] of team owner
  AppTeamMember get ownerMember => this.members.firstWhere((element) => element.user.id == this.ownerId);

  AppTeam._new(RawApiMap raw) : super(Snowflake(raw["id"])) {
    this.iconHash = raw["icon"] as String?;
    this.ownerId = Snowflake(raw["owner_user_id"]);

    this.members = [
    for (final rawMember in raw["members"])
      AppTeamMember._new(rawMember as RawApiMap)
    ];
  }

  /// Returns url to team icon
  String? get teamIconUrl {
    if (iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/team-icons/${this.id.toString()}/${this.iconHash}.png";
    }

    return null;
  }
}

/// Represent membership of user in [AppTeam]
class AppTeamMember {
  /// Basic information of user
  late final AppTeamUser user;

  /// State of membership
  late final int membershipState;

  AppTeamMember._new(RawApiMap raw) {
    this.user = AppTeamUser._new(raw["user"] as RawApiMap);
    this.membershipState = raw["membership_state"] as int;
  }
}

/// Represent user in [AppTeamMember] context
class AppTeamUser extends SnowflakeEntity {
  /// The user's username.
  late final String username;

  /// The user's discriminator.
  late final String discriminator;

  /// The user's avatar hash.
  late final String? avatar;

  AppTeamUser._new(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.username = raw["username"] as String;
    this.discriminator = raw["discriminator"] as String;
    this.avatar = raw["avatar"] as String?;
  }
}
