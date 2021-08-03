part of nyxx_interactions;

/// Partial channel object for interactions
class PartialChannel extends SnowflakeEntity {
  /// Channel name
  late final String name;

  /// Type of channel
  late final ChannelType type;

  /// Permissions of user in channel
  late final Permissions permissions;

  PartialChannel._new(RawApiMap raw): super(Snowflake(raw["id"])) {
    this.name = raw["name"] as String;
    this.type = ChannelType.from(raw["type"] as int);
    this.permissions = Permissions.fromInt(raw["permissions"] as int);
  }
}

/// Additional data for slash command
class InteractionDataResolved {
  /// Resolved [User]s
  late final Iterable<User> users;

  /// Resolved [Member]s
  late final Iterable<Member> members;

  /// Resolved [Role]s
  late final Iterable<Role> roles;

  ///  Resolved [PartialChannel]s
  late final Iterable<PartialChannel> channels;

  InteractionDataResolved._new(RawApiMap raw, Snowflake? guildId, Nyxx client) {
    this.users = [
      if (raw["users"] != null)
        for (final rawUserEntry in (raw["users"] as RawApiMap).entries)
          EntityUtility.createUser(client, rawUserEntry.value as RawApiMap)
    ];

    this.members = [
      if (raw["members"] != null)
        for (final rawMemberEntry in (raw["members"] as RawApiMap).entries)
          EntityUtility.createGuildMember(client, guildId!, {
            ...rawMemberEntry.value as RawApiMap,
            "user": {
              "id": rawMemberEntry.key
            }
          })
    ];

    this.roles = [
      if (raw["roles"] != null)
        for (final rawRoleEntry in (raw["roles"] as RawApiMap).entries)
          EntityUtility.createRole(client, guildId!, rawRoleEntry.value as RawApiMap)
    ];

    this.channels = [
      if (raw["channels"] != null)
        for (final rawChannelEntry in (raw["channels"] as RawApiMap).entries)
          PartialChannel._new(rawChannelEntry.value as RawApiMap)
    ];
  }
}
