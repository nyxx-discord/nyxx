part of nyxx;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  Guild guild;

  GuildCreateEvent._new(Map<String, dynamic> json, Shard shard) {
    this.guild = Guild._new(json['d'] as Map<String, dynamic>, true, true);

    if (_client._options.forceFetchMembers)
      shard.send("REQUEST_GUILD_MEMBERS",
          {"guild_id": guild.id.toString(), "query": "", "limit": 0});

    client.guilds[guild.id] = guild;
    shard.guilds[guild.id] = guild;
    client._events.onGuildCreate.add(this);
  }
}


/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild prior to the update.
  Guild oldGuild;

  /// The guild after the update.
  Guild newGuild;

  GuildUpdateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.newGuild = Guild._new(json['d'] as Map<String, dynamic>);
      this.oldGuild = client.guilds[this.newGuild.id];
      this.newGuild.channels = this.oldGuild.channels;
      this.newGuild.members = this.oldGuild.members;

      client.guilds[oldGuild.id] = newGuild;
      client._events.onGuildUpdate.add(this);
    }
  }
}

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild guild;

  GuildDeleteEvent._new(Map<String, dynamic> json, Shard shard) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['id'] as String)];

      client.guilds.remove(guild.id);
      shard.guilds.remove(guild.id);
      client._events.onGuildDelete.add(this);
    }
  }
}

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Guild guild;

  GuildUnavailableEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = Guild._new(null, false);
      client.guilds[guild.id] = guild;
      client._events.onGuildUnavailable.add(this);
    }
  }
}


/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild guild;

  ///The user that left.
  User user;

  GuildMemberRemoveEvent._new(Map<String, dynamic> json) {
    if (client.ready && json['d']['user']['id'] != client.self.id) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if (this.guild != null) {
        this.guild.memberCount--;
        this.user = User._new(json['d']['user'] as Map<String, dynamic>);
        this.guild.members.remove(user.id);
        client.users.remove(user.id);
        client._events.onGuildMemberRemove.add(this);
      }
    }
  }
}

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member oldMember;

  /// The member after the update.
  Member newMember;

  GuildMemberUpdateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      final guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldMember = guild.members[Snowflake(json['d']['user']['id'] as String)];

      if (oldMember != null && guild != null) {
        this.newMember = oldMember;

        if (oldMember.nickname != json['d']['nick'])
          newMember.nickname = json['d']['nick'] as String;

        var tmpRoles = (json['d']['roles'].cast<String>() as List<String>)
            .map((r) => guild.roles[Snowflake(r)])
            .toList();
        if (oldMember.roles != tmpRoles) newMember.roles = tmpRoles;

        guild.members[oldMember.id] = newMember;
        client.users[oldMember.id] = newMember;
        client._events.onGuildMemberUpdate.add(this);
      }
    }
  }
}

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member member;

  GuildMemberAddEvent._new(Map<String, dynamic> json) {
    if (_client.ready) {
      final Guild guild = _client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if(guild != null) {
        guild.memberCount++;

        this.member = Member._new(json['d'] as Map<String, dynamic>, guild);
        guild.members[member.id] = member;
        client.users[member.id] = member;
        _client._events.onGuildMemberAdd.add(this);
      }
    }
  }
}


/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild guild;

  /// The user that was banned.
  User user;

  GuildBanAddEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.user = User._new(json['d']['user'] as Map<String, dynamic>);

      guild.members.remove(user.id);
      client.users.remove(user.id);
      client._events.onGuildBanAdd.add(this);
    }
  }
}


/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was unbanned from.
  Guild guild;

  /// The user that was unbanned.
  User user;

  GuildBanRemoveEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.user = User._new(json['d']['user'] as Map<String, dynamic>);
      client._events.onGuildBanRemove.add(this);
    }
  }
}

/// Fired when emojis are updated
class GuildEmojisUpdateEvent {
  /// New list of changes emojis
  Map<Snowflake, GuildEmoji> emojis;

  GuildEmojisUpdateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
      client.guilds[Snowflake(json['d']['guild_id'] as String)];
      emojis = Map();
      json['d']['emojis'].forEach((o) {
        var emoji = GuildEmoji._new(o as Map<String, dynamic>, guild);
        guild.emojis[emoji.id] = emoji;
        emojis[emoji.id] = emoji;
      });
      client._events.onGuildEmojisUpdate.add(this);
    }
  }
}

/// Sent when a role is created.
class RoleCreateEvent {
  /// The role that was created.
  Role role;

  RoleCreateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
      client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.role = Role._new(json['d']['role'] as Map<String, dynamic>, guild);

      guild.roles[role.id] = role;
      client._events.onRoleCreate.add(this);
    }
  }
}


/// Sent when a role is deleted.
class RoleDeleteEvent {
  /// The role that was deleted.
  Role role;

  RoleDeleteEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
      client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if (guild != null) {
        this.role = guild.roles[Snowflake(json['d']['role_id'] as String)];
        guild.roles.remove(role.id);
        client._events.onRoleDelete.add(this);
      }
    }
  }
}

/// Sent when a role is updated.
class RoleUpdateEvent {
  /// The role prior to the update.
  Role oldRole;

  /// The role after the update.
  Role newRole;

  RoleUpdateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
      client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldRole = guild.roles[Snowflake(json['d']['role']['id'] as String)];
      this.newRole =
          Role._new(json['d']['role'] as Map<String, dynamic>, guild);

      oldRole.guild.roles[oldRole.id] = newRole;
      client._events.onRoleUpdate.add(this);
    }
  }
}
