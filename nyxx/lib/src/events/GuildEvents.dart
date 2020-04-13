part of nyxx;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  late final Guild guild;

  GuildCreateEvent._new(Map<String, dynamic> json, Shard shard, Nyxx client) {
    this.guild =
        Guild._new(client, json['d'] as Map<String, dynamic>, true, true);

    if (client._options.forceFetchMembers)
      shard.send("REQUEST_GUILD_MEMBERS",
          {"guild_id": guild.id.toString(), "query": "", "limit": 0});

    client.guilds[guild.id] = guild;
    shard.guilds[guild.id] = guild;
  }
}

/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild prior to the update.
  Guild? oldGuild;

  /// The guild after the update.
  late final Guild newGuild;

  GuildUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.newGuild = Guild._new(client, json['d'] as Map<String, dynamic>);
    this.oldGuild = client.guilds[this.newGuild.id];
    /// TODO: NNBD - To consider

    if(oldGuild != null) {
      this.newGuild.channels = this.oldGuild!.channels;
      this.newGuild.members = this.oldGuild!.members;

      client.guilds[oldGuild!.id] = newGuild;
    }
  }
}

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild? guild;

  GuildDeleteEvent._new(Map<String, dynamic> json, Shard shard, Nyxx client) {
    this.guild = client.guilds[Snowflake(json['d']['id'] as String)];
    /// TODO: NNBD - To consider
    client.guilds.remove(guild!.id);
    shard.guilds.remove(guild!.id);
  }
}

/// Sent when you leave a guild or it becomes unavailable.
class GuildUnavailableEvent {
  /// An unavailable guild object.
  Snowflake? guildId;

  GuildUnavailableEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.guildId = Snowflake(json['d']['id'] as String);
    var guild = client.guilds[guildId!];
    /// TODO: NNBD - To consider
    if(guild != null) {
      client.guilds[guildId!]!.dispose();
      client.guilds.remove(guildId!);
    }
  }
}

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild? guild;

  ///The user that left.
  User? user;

  GuildMemberRemoveEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready && json['d']['user']['id'] != client.self.id) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if (this.guild != null) {
        this.user =
            User._new(json['d']['user'] as Map<String, dynamic>, client);
        this.guild!.members.remove(user!.id);
        client.users.remove(user!.id);
      }
    }
  }
}

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member? oldMember;

  /// The member after the update.
  Member? newMember;

  GuildMemberUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      final guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldMember =
          guild?.members[Snowflake(json['d']['user']['id'] as String)];

      if (oldMember != null && guild != null) {
        this.newMember = oldMember;

        if (oldMember?.nickname != json['d']['nick'])
          newMember?.nickname = json['d']['nick'] as String;

        // TODO: NNBD - To consider
        var tmpRoles = (json['d']['roles'].cast<String>() as List<String>)
            .map((r) => guild.roles[Snowflake(r)] as Role)
            .toList();

        if (oldMember?.roles != tmpRoles) newMember?.roles = tmpRoles;

        guild.members[oldMember!.id] = newMember!;
        client.users[oldMember!.id] = newMember!;
      }
    }
  }
}

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member? member;

  GuildMemberAddEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      final Guild? guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if (guild != null) {
        this.member =
            Member._standard(json['d'] as Map<String, dynamic>, guild, client);
        guild.members[member!.id] = member!;
        client.users[member!.id] = member!;
      }
    }
  }
}

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild? guild;

  /// The user that was banned.
  late final User user;

  GuildBanAddEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
    this.user = User._new(json['d']['user'] as Map<String, dynamic>, client);

    if(guild != null) {
      guild!.members.remove(user.id);
    }

    client.users.remove(user.id);
  }
}

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was unbanned from.
  Guild? guild;

  /// The user that was unbanned.
  late final User user;

  GuildBanRemoveEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
    this.user = User._new(json['d']['user'] as Map<String, dynamic>, client);
  }
}

/// Fired when emojis are updated
class GuildEmojisUpdateEvent {
  /// New list of changes emojis
  late final Map<Snowflake, GuildEmoji> emojis;

  GuildEmojisUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      final Guild? guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];

      emojis = Map();
      if(guild != null) {
        json['d']['emojis'].forEach((o) {
          var emoji = GuildEmoji._new(o as Map<String, dynamic>, guild, client);
          guild.emojis[emoji.id] = emoji;
          emojis[emoji.id] = emoji;
        });
      }
    }
  }
}

/// Sent when a role is created.
class RoleCreateEvent {
  /// The role that was created.
  Role? role;

  RoleCreateEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (client.ready) {
      final Guild? guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if(guild != null) {
        this.role =
            Role._new(json['d']['role'] as Map<String, dynamic>, guild, client);

        guild.roles[role!.id] = role!;
      }
    }
  }
}

/// Sent when a role is deleted.
class RoleDeleteEvent {
  /// The role that was deleted.
  Role? role;

  RoleDeleteEvent._new(Map<String, dynamic> json, Nyxx client) {
    final Guild? guild =
        client.guilds[Snowflake(json['d']['guild_id'] as String)];

    if (guild != null) {
      this.role = guild.roles[Snowflake(json['d']['role_id'] as String)];
      guild.roles.remove(role!.id);
    }
  }
}

/// Sent when a role is updated.
class RoleUpdateEvent {
  /// The role prior to the update.
  Role? oldRole;

  /// The role after the update.
  Role? newRole;

  RoleUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    final Guild? guild =
        client.guilds[Snowflake(json['d']['guild_id'] as String)];

    if(guild != null) {
      this.oldRole = guild.roles[Snowflake(json['d']['role']['id'] as String)];
      this.newRole =
          Role._new(json['d']['role'] as Map<String, dynamic>, guild, client);

      if(oldRole != null) {
        oldRole!.guild.roles[oldRole!.id] = newRole!;
      } else {
        guild.roles.add(newRole!.id, newRole!);
      }
    }
  }
}
