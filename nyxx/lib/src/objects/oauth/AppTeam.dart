part of nyxx;

class AppTeam extends SnowflakeEntity{
  late final String? iconHash;
  late final Snowflake ownerId;

  late final List<AppTeamMember> members;

  AppTeam._new(Map<String, dynamic> raw) : super(Snowflake(raw['id'])) {
    this.iconHash = raw['icon'] as String?;
    this.ownerId = Snowflake(raw['owner_user_id']);

    this.members = List();
    for(Map<String, dynamic> obj in raw['members']) {
      this.members.add(AppTeamMember._new(obj));
    }
  }

  String? get teamIconUrl {
    if(iconHash != null) {
      return "https://cdn.discordapp.com/team-icons/team_id/team_icon.png";
    }

    return null;
  }
}

class AppTeamMember {
  late final AppTeamUser user;
  late final int membershipState;

  AppTeamMember._new(Map<String, dynamic> raw) {
    this.user = AppTeamUser._new(raw['user'] as Map<String, dynamic>);
    this.membershipState = raw['membership_state'] as int;
  }
}

class AppTeamUser extends SnowflakeEntity {
  /// The user's username.
  late final String username;

  /// The user's discriminator.
  late final String discriminator;

  /// The user's avatar hash.
  late final String? avatar;

  AppTeamUser._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this.username = raw['username'] as String;
    this.discriminator = raw['discriminator'] as String;
    this.avatar = raw['avatar'] as String?;
  }
}