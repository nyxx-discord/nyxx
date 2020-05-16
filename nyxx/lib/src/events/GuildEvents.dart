part of nyxx;

/// Sent when the bot joins a guild.
class GuildCreateEvent {
  /// The guild created.
  late final Guild guild;

  GuildCreateEvent._new(Map<String, dynamic> raw, Shard shard, Nyxx client) {
    this.guild = Guild._new(client, raw['d'] as Map<String, dynamic>, true, true);
    client.guilds[guild.id] = guild;

    if (client._options.forceFetchMembers) {
      shard.send(OPCodes.requestGuildMember,
          {"guild_id": guild.id.toString(), "query": "", "limit": 0});
    }
  }
}

/// Sent when a guild is updated.
class GuildUpdateEvent {
  /// The guild after the update.
  late final Guild guild;

  GuildUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.guild = Guild._new(client, json['d'] as Map<String, dynamic>);

    // TODO: Cache should be moved to updated guild?
    /*
    if(oldGuild != null) {
      this.newGuild.channels = this.oldGuild!.channels;
      this.newGuild.members = this.oldGuild!.members;
    }
*/
      client.guilds[guild.id] = guild;
  }
}

/// Sent when you leave a guild.
class GuildDeleteEvent {
  /// The guild.
  Guild? guild;

  /// ID og guild
  late final Snowflake guildId;

  /// True if guild is unavailable which means disconnected due discord side problems
  /// False if user was kicked from guild
  late final bool unavailable;

  GuildDeleteEvent._new(Map<String, dynamic> raw, Shard shard, Nyxx client) {
    this.guildId = Snowflake(raw['d']['id']);
    this.unavailable = raw['d']['unavailable'] as bool;
    this.guild = client.guilds[this.guildId];

    client.guilds.remove(guildId);
  }
}

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild? guild;

  /// ID of the guild
  late final Snowflake guildId;

  ///The user that left.
  late final User user;

  GuildMemberRemoveEvent._new(Map<String, dynamic> json, Nyxx client) {
    var userSnowflake = Snowflake(json['d']['user']['id']);

    var user = client.users[userSnowflake];

    if(user == null) {
      this.user = User._new(json['d']['user'] as Map<String, dynamic>, client);
    } else {
      this.user = user;
    }

    this.guildId = Snowflake(json['d']['guild_id']);
    this.guild = client.guilds[this.guildId];

    client.users.remove(this.user.id);
    if(this.guild != null) {
      this.guild!.members.remove(this.user.id);
    }
  }
}

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member after the update if member is updated.
  late final Member? member;

  /// User if user is updated. Will be null if member is not null.
  late final User? user;

  GuildMemberUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    var guild = client.guilds[Snowflake(raw['d']['guild_id'])];

    if(guild == null) {
      return;
    }

    var member = guild.members[Snowflake(raw['d']['user']['id'])];

    if(member == null) {
      return;
    }

    var nickname = raw['d']['nickname'] as String?;
    var roles = (raw['d']['roles'] as List<dynamic>)
        .map((str) => guild.roles[Snowflake(str)]!).toList();

    if(member._updateMember(nickname, roles)) {
      return;
    }

    var user = User._new(raw['d']['user'] as Map<String, dynamic>, client);
    client.users[user.id] = user;
  }
}

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  late final Member? member;

  GuildMemberAddEvent._new(Map<String, dynamic> raw, Nyxx client) {
    var guild = client.guilds[Snowflake(raw['d']['guild_id'] as String)];

    if(guild == null) {
      return;
    }

    this.member = Member._standard(raw['d'] as Map<String, dynamic>, guild, client);

    guild.members[member!.id] = member!;
    if(!client.users.hasKey(member!.id)) {
      client.users[member!.id] = member!;
    }
  }
}

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild? guild;

  /// Id of the guild
  late final Snowflake guildId;

  /// The user that was banned.
  late final User user;

  GuildBanAddEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.guildId = Snowflake(raw['d']['guild_id']);

    var user = client.users[Snowflake(raw['d']['user']['id'])];

    if(user == null) {
      this.user = User._new(raw['d']['user'] as Map<String, dynamic>, client);
    } else {
      this.user = user;
    }

    this.guild = client.guilds[guildId];

    client.users.remove(this.user.id);
    if(guild != null) {
      guild!.members.remove(this.user.id);
    }
  }
}

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was banned from.
  Guild? guild;

  /// Id of the guild
  late final Snowflake guildId;

  /// The user that was banned.
  late final User user;

  GuildBanRemoveEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.guildId = Snowflake(raw['d']['guild_id']);

    var user = client.users[Snowflake(raw['d']['user']['id'])];

    if(user == null) {
      this.user = User._new(raw['d']['user'] as Map<String, dynamic>, client);
    } else {
      this.user = user;
    }

    this.guild = client.guilds[guildId];

    client.users.remove(this.user.id);
    if(guild != null) {
      guild!.members.remove(this.user.id);
    }
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
