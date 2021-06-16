part of nyxx;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  late final Guild guild;

  GuildCreateEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = Guild._new(client, raw["d"] as RawApiMap, true);
    client.guilds[guild.id] = guild;
  }
}

/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild after the update.
  late final Guild guild;

  GuildUpdateEvent._new(RawApiMap json, Nyxx client) {
    this.guild = Guild._new(client, json["d"] as RawApiMap);

    final oldGuild = client.guilds[this.guild.id];
    if(oldGuild != null) {
      this.guild.members.addMap(oldGuild.members.asMap);
    }

    client.guilds[guild.id] = guild;
  }
}

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  late final Cacheable<Snowflake, Guild> guild;

  /// True if guild is unavailable which means disconnected due discord side problems
  /// False if user was kicked from guild
  late final bool unavailable;

  GuildDeleteEvent._new(RawApiMap raw, Nyxx client) {
    this.unavailable = raw["d"]["unavailable"] as bool;
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["id"]));

    client.guilds.remove(guild.id);
  }
}

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  late final Cacheable<Snowflake, Guild> guild;

  ///The user that left.
  late final User user;

  GuildMemberRemoveEvent._new(RawApiMap json, Nyxx client) {
    this.user = User._new(client, json["d"]["user"] as RawApiMap);
    this.guild = _GuildCacheable(client, Snowflake(json["d"]["guild_id"]));

    final guildInstance = this.guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.members.remove(this.user.id);
    }
  }
}

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member after the update if member is updated.
  late final Cacheable<Snowflake, Member> member;

  /// User if user is updated. Will be null if member is not null.
  late final User user;

  /// Guild in which member is
  late final Cacheable<Snowflake, Guild> guild;

  GuildMemberUpdateEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.member = _MemberCacheable(client, Snowflake(raw["d"]["user"]["id"]), guild);

    final user = User._new(client, raw["d"]["user"] as RawApiMap);
    if (client._cacheOptions.userCachePolicyLocation.event) {
      client.users[user.id] = user;
    }

    final memberInstance = this.member.getFromCache();
    if (memberInstance == null) {
      return;
    }

    final guildInstance = this.guild.getFromCache();
    if (guildInstance == null) {
      return;
    }

    final nickname = raw["d"]["nickname"] as String?;
    final roles = (raw["d"]["roles"] as List<dynamic>).map((str) => Snowflake(str)).toList();
    final boostingSince = DateTime.tryParse(raw["premium_since"] as String? ?? "");

    memberInstance._updateMember(nickname, roles, boostingSince);
  }
}

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  late final Member member;

  /// User object of member that joined
  late final User user;

  /// Guild where used was added
  late final Cacheable<Snowflake, Guild> guild;

  GuildMemberAddEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.member = Member._new(client, raw["d"] as RawApiMap, this.guild.id);
    this.user = User._new(client, raw["d"]["user"] as RawApiMap);

    if (!client.users.hasKey(this.user.id) && client._cacheOptions.userCachePolicyLocation.event) {
      client.users[user.id] = user;
    }

    final guildInstance = this.guild.getFromCache();
    if (guildInstance == null) {
      return;
    }

    if (client._cacheOptions.memberCachePolicyLocation.event && client._cacheOptions.memberCachePolicy.canCache(this.member)) {
      guildInstance.members[this.member.id] = member;
    }
  }
}

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  late final Cacheable<Snowflake, Guild> guild;

  /// The user that was banned.
  late final User user;

  GuildBanAddEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.user = User._new(client, raw["d"]["user"] as RawApiMap);
  }
}

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was banned from.
  late final Cacheable<Snowflake, Guild> guild;

  /// The user that was banned.
  late final User user;

  GuildBanRemoveEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.user = User._new(client, raw["d"]["user"] as RawApiMap);
  }
}

/// Fired when emojis are updated
class GuildEmojisUpdateEvent {
  /// List of modified emojis
  late final List<GuildEmoji> emojis = [];

  /// The guild that the member was banned from.
  late final Cacheable<Snowflake, Guild> guild;

  GuildEmojisUpdateEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    final guildInstance = this.guild.getFromCache();
    for(final rawEmoji in raw["d"]["emojis"]) {
      final emoji = GuildEmoji._new(client, rawEmoji as RawApiMap, this.guild.id);

      this.emojis.add(emoji);

      if (guildInstance != null) {
        guildInstance.emojis[emoji.id] = emoji;
      }
    }
  }
}

/// Sent when a role is created.
class RoleCreateEvent {
  /// The role that was created.
  late final Role role;

  /// The guild that the member was banned from.
  late final Cacheable<Snowflake, Guild> guild;

  RoleCreateEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    this.role = Role._new(client, raw["d"]["role"] as RawApiMap, this.guild.id);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.roles[role.id] = role;
    }
  }
}

/// Sent when a role is deleted.
class RoleDeleteEvent {
  /// The role that was deleted, if available
  late final Role? role;

  /// Id of tole that was deleted
  late final Snowflake roleId;

  /// The guild that the member was banned from.
  late final Cacheable<Snowflake, Guild> guild;

  RoleDeleteEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.roleId = Snowflake(raw["d"]["role_id"]);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      this.role = guildInstance.roles[this.roleId];
      guildInstance.roles.remove(role!.id);
    } else {
      this.role = null;
    }
  }
}

/// Sent when a role is updated.
class RoleUpdateEvent {
  /// The role after the update.
  late final Role role;

  /// The guild that the member was banned from.
  late final Cacheable<Snowflake, Guild> guild;

  RoleUpdateEvent._new(RawApiMap raw, Nyxx client) {
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.role = Role._new(client, raw["d"]["role"] as RawApiMap, this.guild.id);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.roles[role.id] = role;
    }
  }
}
