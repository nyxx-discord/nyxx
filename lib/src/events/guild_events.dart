import 'package:nyxx/src/core/channel/guild/text_guild_channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/guild/auto_moderation.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/sticker.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IGuildCreateEvent {
  /// The guild created.
  IGuild get guild;
}

/// Sent when the bot joins a guild.
class GuildCreateEvent implements IGuildCreateEvent {
  /// The guild created.
  @override
  late final IGuild guild;

  /// Creates an instance of [GuildCreateEvent]
  GuildCreateEvent(RawApiMap raw, INyxx client) {
    guild = Guild(client, raw["d"] as RawApiMap, true);
    client.guilds[guild.id] = guild;
  }
}

abstract class IGuildUpdateEvent {
  /// The guild after the update.
  IGuild get guild;

  /// The guild before the update, if it was cached.
  IGuild? get oldGuild;
}

/// Sent when a guild is updated.
class GuildUpdateEvent implements IGuildUpdateEvent {
  /// The guild after the update.
  @override
  late final IGuild guild;

  @override
  late final IGuild? oldGuild;

  /// Creates an instance of [GuildUpdateEvent]
  GuildUpdateEvent(RawApiMap json, INyxx client) {
    guild = Guild(client, json["d"] as RawApiMap);

    oldGuild = client.guilds[guild.id];
    if (oldGuild != null) {
      guild.members.addAll(oldGuild!.members);
    }

    client.guilds[guild.id] = guild;
  }
}

abstract class IGuildDeleteEvent {
  /// The guild.
  Cacheable<Snowflake, IGuild> get guild;

  /// True if guild is unavailable which means disconnected due discord side problems
  /// False if user was kicked from guild
  bool get unavailable;
}

/// Sent when you leave a guild.
class GuildDeleteEvent implements IGuildDeleteEvent {
  /// The guild.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// True if guild is unavailable which means disconnected due discord side problems
  /// False if user was kicked from guild
  @override
  late final bool unavailable;

  /// Creates an instance of [GuildDeleteEvent]
  GuildDeleteEvent(RawApiMap raw, INyxx client) {
    unavailable = raw["d"]["unavailable"] as bool? ?? false;
    guild = GuildCacheable(client, Snowflake(raw["d"]["id"]));

    client.guilds.remove(guild.id);
  }
}

abstract class IGuildMemberRemoveEvent {
  /// The guild the user left.
  Cacheable<Snowflake, IGuild> get guild;

  ///The user that left.
  IUser get user;
}

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent implements IGuildMemberRemoveEvent {
  /// The guild the user left.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  ///The user that left.
  @override
  late final IUser user;

  /// Creates an instance of [GuildMemberRemoveEvent]
  GuildMemberRemoveEvent(RawApiMap json, INyxx client) {
    user = User(client, json["d"]["user"] as RawApiMap);
    guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.members.remove(user.id);
    }
  }
}

abstract class IGuildMemberUpdateEvent {
  /// The member after the update if member is updated.
  Cacheable<Snowflake, IMember> get member;

  /// The user of the updated member.
  IUser get user;

  /// The user of the member before it was updated, if it was cached.
  IUser? get oldUser;

  /// Guild in which member is
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a member is updated.
class GuildMemberUpdateEvent implements IGuildMemberUpdateEvent {
  /// The member after the update if member is updated.
  @override
  late final Cacheable<Snowflake, IMember> member;

  /// User if user is updated. Will be null if member is not null.
  @override
  late final IUser user;

  @override
  late final IUser? oldUser;

  /// Guild in which member is
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [GuildMemberUpdateEvent]
  GuildMemberUpdateEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    member = MemberCacheable(client, Snowflake(raw["d"]["user"]["id"]), guild);
    user = User(client, raw["d"]["user"] as RawApiMap);

    oldUser = client.users[user.id];

    if (client.cacheOptions.userCachePolicyLocation.event) {
      client.users[user.id] = user;
    }

    final memberInstance = member.getFromCache();
    if (memberInstance == null) {
      return;
    }

    final guildInstance = guild.getFromCache();
    if (guildInstance == null) {
      return;
    }

    final nickname = raw["d"]["nickname"] as String?;
    final roles = (raw["d"]["roles"] as RawApiList).map(Snowflake.new).toList();
    final boostingSince = DateTime.tryParse(raw["premium_since"] as String? ?? "");

    (memberInstance as Member).updateMember(nickname, roles, boostingSince);
  }
}

abstract class IGuildMemberAddEvent {
  /// The member that joined.
  late final IMember member;

  /// User object of member that joined
  late final IUser user;

  /// Guild where used was added
  late final Cacheable<Snowflake, IGuild> guild;
}

/// Sent when a member joins a guild.
class GuildMemberAddEvent implements IGuildMemberAddEvent {
  /// The member that joined.
  @override
  late final IMember member;

  /// User object of member that joined
  @override
  late final IUser user;

  /// Guild where used was added
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [GuildMemberAddEvent]
  GuildMemberAddEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    member = Member(client, raw["d"] as RawApiMap, guild.id);
    user = User(client, raw["d"]["user"] as RawApiMap);

    if (client.cacheOptions.userCachePolicyLocation.event) {
      client.users[user.id] = user;
    }

    final guildInstance = guild.getFromCache();
    if (guildInstance == null) {
      return;
    }

    if (client.cacheOptions.memberCachePolicyLocation.event && client.cacheOptions.memberCachePolicy.canCache(member)) {
      guildInstance.members[member.id] = member;
    }
  }
}

abstract class IGuildBanAddEvent {
  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;

  /// The user that was banned.
  IUser get user;
}

/// Sent when a member is banned.
class GuildBanAddEvent implements IGuildBanAddEvent {
  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The user that was banned.
  @override
  late final IUser user;

  /// Creates an instance of [GuildBanAddEvent]
  GuildBanAddEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    user = User(client, raw["d"]["user"] as RawApiMap);
  }
}

abstract class IGuildBanRemoveEvent {
  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;

  /// The user that was banned.
  IUser get user;
}

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent implements IGuildBanRemoveEvent {
  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The user that was banned.
  @override
  late final IUser user;

  /// Creates an instance of [GuildBanRemoveEvent]
  GuildBanRemoveEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    user = User(client, raw["d"]["user"] as RawApiMap);
  }
}

abstract class IGuildEmojisUpdateEvent {
  /// List of modified emojis
  List<IGuildEmoji> get emojis;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Fired when emojis are updated
class GuildEmojisUpdateEvent implements IGuildEmojisUpdateEvent {
  /// List of modified emojis
  @override
  late final List<IGuildEmoji> emojis = [];

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [GuildEmojisUpdateEvent]
  GuildEmojisUpdateEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    final guildInstance = guild.getFromCache();
    for (final rawEmoji in raw["d"]["emojis"]) {
      final emoji = GuildEmoji(client, rawEmoji as RawApiMap, guild.id);

      emojis.add(emoji);

      if (guildInstance != null) {
        guildInstance.emojis[emoji.id] = emoji;
      }
    }
  }
}

abstract class IRoleCreateEvent {
  /// The role that was created.
  IRole get role;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a role is created.
class RoleCreateEvent implements IRoleCreateEvent {
  /// The role that was created.
  @override
  late final IRole role;

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [RoleCreateEvent]
  RoleCreateEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    role = Role(client, raw["d"]["role"] as RawApiMap, guild.id);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.roles[role.id] = role;
    }
  }
}

abstract class IRoleDeleteEvent {
  /// Id of tole that was deleted
  Cacheable<Snowflake, IRole>? get role;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a role is deleted.
class RoleDeleteEvent implements IRoleDeleteEvent {
  /// Id of tole that was deleted
  @override
  late final Cacheable<Snowflake, IRole>? role;

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [RoleDeleteEvent]
  RoleDeleteEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      role = RoleCacheable(client, Snowflake(raw["d"]["role_id"]), guild);
      guildInstance.roles.remove(role!.id);
    } else {
      role = null;
    }
  }
}

abstract class IRoleUpdateEvent {
  /// The role after the update.
  IRole get role;

  /// The role before it was updated, if it was cached.
  IRole? get oldRole;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a role is updated.
class RoleUpdateEvent implements IRoleUpdateEvent {
  /// The role after the update.
  @override
  late final IRole role;

  @override
  late final IRole? oldRole;

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [RoleUpdateEvent]
  RoleUpdateEvent(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    role = Role(client, raw["d"]["role"] as RawApiMap, guild.id);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      oldRole = guildInstance.roles[role.id];
      guildInstance.roles[role.id] = role;
    } else {
      oldRole = null;
    }
  }
}

abstract class IGuildStickerUpdate {
  /// Cacheable of guild where stickers changed
  Cacheable<Snowflake, IGuild> get guild;

  /// List of stickers
  List<IGuildSticker> get stickers;
}

/// Sent when a guild's stickers have been updated.
class GuildStickerUpdate implements IGuildStickerUpdate {
  /// Cacheable of guild where stickers changed
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// List of stickers
  @override
  late final List<IGuildSticker> stickers;

  /// Creates an instance of [GuildStickerUpdate]
  GuildStickerUpdate(RawApiMap raw, INyxx client) {
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    stickers = [for (final rawSticker in raw["d"]["stickers"]) GuildSticker(rawSticker as RawApiMap, client)];
  }
}

abstract class IGuildEventCreateEvent {
  IGuildEvent get event;
}

class GuildEventCreateEvent implements IGuildEventCreateEvent {
  @override
  late final IGuildEvent event;

  GuildEventCreateEvent(RawApiMap raw, INyxx client) {
    event = GuildEvent(raw['d'] as RawApiMap, client);
    event.guild.getFromCache()?.scheduledEvents[event.id] = event;
  }
}

abstract class IGuildEventUpdateEvent {
  /// The newly edited event.
  IGuildEvent get event;

  /// The old event before it's update.
  IGuildEvent? get oldEvent;
}

class GuildEventUpdateEvent implements IGuildEventUpdateEvent {
  @override
  late final IGuildEvent event;

  @override
  late final IGuildEvent? oldEvent;

  GuildEventUpdateEvent(RawApiMap raw, INyxx client) {
    event = GuildEvent(raw['d'] as RawApiMap, client);
    oldEvent = event.guild.getFromCache()?.scheduledEvents[event.id];
    event.guild.getFromCache()?.scheduledEvents.update(event.id, (_) => event, ifAbsent: () => event);
  }
}

abstract class IGuildEventDeleteEvent {
  IGuildEvent get event;
}

class GuildEventDeleteEvent implements IGuildEventDeleteEvent {
  @override
  late final IGuildEvent event;

  GuildEventDeleteEvent(RawApiMap raw, INyxx client) {
    event = GuildEvent(raw['d'] as RawApiMap, client);
    event.guild.getFromCache()?.scheduledEvents.remove(event.id);
  }
}

abstract class IAutoModerationRuleCreateEvent {
  /// The created rule.
  IAutoModerationRule get rule;
}

class AutoModerationRuleCreateEvent implements IAutoModerationRuleCreateEvent {
  @override
  late final IAutoModerationRule rule;

  AutoModerationRuleCreateEvent(RawApiMap raw, INyxx client) {
    rule = AutoModerationRule(raw['d'] as RawApiMap, client);
    client.guilds[rule.guild.id]?.autoModerationRules[rule.id] = rule;
  }
}

abstract class IAutoModerationRuleUpdateEvent {
  /// The updated rule.
  IAutoModerationRule get rule;

  /// The old rule before it's update.
  IAutoModerationRule? get oldRule;
}

class AutoModerationRuleUpdateEvent implements IAutoModerationRuleUpdateEvent {
  @override
  late final IAutoModerationRule rule;

  @override
  late final IAutoModerationRule? oldRule;

  AutoModerationRuleUpdateEvent(RawApiMap raw, INyxx client) {
    rule = AutoModerationRule(raw['d'] as RawApiMap, client);
    final guild = client.guilds[rule.guild.id];
    oldRule = guild?.autoModerationRules[rule.id];
    if (guild == null) {
      return;
    }
    guild.autoModerationRules.update(rule.id, (_) => rule, ifAbsent: () => rule);
  }
}

abstract class IAutoModerationRuleDeleteEvent {
  /// The deleted rule.
  IAutoModerationRule get rule;
}

class AutoModerationRuleDeleteEvent implements IAutoModerationRuleDeleteEvent {
  @override
  late final IAutoModerationRule rule;

  AutoModerationRuleDeleteEvent(RawApiMap raw, INyxx client) {
    rule = AutoModerationRule(raw['d'] as RawApiMap, client);
    client.guilds[rule.guild.id]?.autoModerationRules.remove(rule.id);
  }
}

/// When a webhook is created, updated or deleted.
abstract class IWebhookUpdateEvent {
  /// The channel that points this webhook to.
  Cacheable<Snowflake, ITextChannel> get channel;

  /// The guild this webhook was created/updated/deleted.
  Cacheable<Snowflake, IGuild> get guild;
}

class WebhookUpdateEvent implements IWebhookUpdateEvent {
  @override
  late final Cacheable<Snowflake, ITextChannel> channel;

  @override
  late final Cacheable<Snowflake, IGuild> guild;

  WebhookUpdateEvent(RawApiMap raw, INyxx client) {
    channel = ChannelCacheable(client, Snowflake(raw['d']['channel_id']));
    guild = GuildCacheable(client, Snowflake(raw['d']['guild_id']));
  }
}

abstract class IAutoModerationActionExecutionEvent implements SnowflakeEntity {
  /// The guild where this action was executed.
  Cacheable<Snowflake, IGuild> get guild;

  /// The action which was executed.
  ActionStructure get action;

  /// The trigger type of rule which was triggered.
  TriggerTypes get triggerType;

  /// The member which generated the content which triggered the rule.
  Cacheable<Snowflake, IMember> get member;

  /// The channel in which user content was posted.
  Cacheable<Snowflake, ITextGuildChannel>? get channel;

  /// The message of any user message which content belongs to.
  ///
  /// This will not be present if the message was blocked by automod or the content was not part of the message.
  Cacheable<Snowflake, IMessage>? get message;

  /// The message id of any system auto moderation messages posted as a result of this action.
  ///
  /// `null` if the [action.actionType] is not [ActionTypes.sendAlertMessage].
  Snowflake? get alertSystemMessage;

  /// The member generated text content.
  ///
  /// An empty string if you have not the message content privilegied intent.
  String get content;

  /// The word or phrase configured in the rule that triggered the rule
  String? get matchedKeyword;

  /// The substring in content that triggered the rule.
  ///
  /// An empty string if you have not the message content privilegied intent.
  String get matchedContent;
}

class AutoModeratioActionExecutionEvent extends SnowflakeEntity implements IAutoModerationActionExecutionEvent {
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  @override
  late final ActionStructure action;

  @override
  late final TriggerTypes triggerType;

  @override
  late final Cacheable<Snowflake, IMember> member;

  @override
  late final Cacheable<Snowflake, ITextGuildChannel>? channel;

  @override
  late final Cacheable<Snowflake, IMessage>? message;

  @override
  late final Snowflake? alertSystemMessage;

  @override
  late final String content;

  @override
  late final String? matchedKeyword;

  @override
  late final String matchedContent;

  AutoModeratioActionExecutionEvent(RawApiMap rawPayload, INyxx client) : super(Snowflake(rawPayload['d']['rule_id'])) {
    final raw = rawPayload['d'];
    guild = GuildCacheable(client, Snowflake(raw['guild_id'] as String));
    action = ActionStructure(raw['action'] as RawApiMap, client);
    triggerType = TriggerTypes.fromValue(raw['rule_trigger_type'] as int);
    member = MemberCacheable(client, Snowflake(raw['user_id']), guild);
    channel = raw['channel_id'] != null ? ChannelCacheable(client, Snowflake(raw['channel_id'])) : null;
    message = raw['message_id'] != null && channel != null ? MessageCacheable(client, Snowflake(raw['message_id']), channel!) : null;
    alertSystemMessage = raw['alert_system_message_id'] != null ? Snowflake(raw['alert_system_message_id']) : null;
    content = raw['content'] as String;
    matchedKeyword = raw['matched_keyword'] != null ? raw['matched_keyword'] as String : null;
    matchedContent = raw['matched_content'] as String;
  }
}
