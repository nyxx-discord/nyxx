import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/channel/types/dm.dart';
import 'package:nyxx/src/models/channel/types/group_dm.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/commands/application_command_permissions.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/events/application_command.dart';
import 'package:nyxx/src/models/gateway/events/auto_moderation.dart';
import 'package:nyxx/src/models/gateway/events/channel.dart';
import 'package:nyxx/src/models/gateway/events/entitlement.dart';
import 'package:nyxx/src/models/gateway/events/guild.dart';
import 'package:nyxx/src/models/gateway/events/integration.dart';
import 'package:nyxx/src/models/gateway/events/interaction.dart';
import 'package:nyxx/src/models/gateway/events/invite.dart';
import 'package:nyxx/src/models/gateway/events/message.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';
import 'package:nyxx/src/models/gateway/events/ready.dart';
import 'package:nyxx/src/models/gateway/events/stage_instance.dart';
import 'package:nyxx/src/models/gateway/events/voice.dart';
import 'package:nyxx/src/models/gateway/events/webhook.dart';
import 'package:nyxx/src/models/guild/audit_log.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/guild_preview.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/guild/template.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/sticker/global_sticker.dart';
import 'package:nyxx/src/models/sticker/guild_sticker.dart';
import 'package:nyxx/src/models/sticker/sticker_pack.dart';
import 'package:nyxx/src/models/sku.dart';
import 'package:nyxx/src/models/subscription.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';
import 'package:nyxx/src/models/webhook.dart';

extension CacheUpdates on NyxxRest {
  /// Update the caches for this client using [entity] by registering (or removing, if [entity] is a delete event) any cacheable entities reachable from [entity].
  void updateCacheWith(Object? entity) => switch (entity) {
        // "Root" types - with their own cache

        VoiceState() => () {
            // ignore: deprecated_member_use_from_same_package
            entity.manager.cache[entity.cacheKey] = entity;
            entity.guild?.voiceStates[entity.userId] = entity;

            updateCacheWith(entity.member);
          }(),
        StageInstance() => entity.manager.stageInstanceCache[entity.id] = entity,
        CommandPermissions() => entity.manager.permissionsCache[entity.id] = entity,
        AuditLogEntry() => entity.manager.cache[entity.id] = entity,
        Channel() => () {
            entity.manager.cache[entity.id] = entity;

            if (entity case DmChannel(:final recipient)) {
              updateCacheWith(recipient);
            }
            if (entity case GroupDmChannel(:final recipients)) {
              recipients.forEach(updateCacheWith);
            }
          }(),
        Entitlement() => entity.manager.cache[entity.id] = entity,
        Integration() => () {
            entity.manager.cache[entity.id] = entity;

            updateCacheWith(entity.user);
          }(),
        GlobalSticker() => entity.manager.cache[entity.id] = entity,
        User() => entity.manager.cache[entity.id] = entity,
        ApplicationCommand() => entity.manager.cache[entity.id] = entity,
        AutoModerationRule() => entity.manager.cache[entity.id] = entity,
        Emoji() => () {
            entity.manager.cache[entity.id] = entity;

            if (entity case GuildEmoji(:final user?)) {
              updateCacheWith(user);
            }
          }(),
        Guild() => () {
            entity.manager.cache[entity.id] = entity;

            entity.roleList.forEach(updateCacheWith);
            entity.emojiList.forEach(updateCacheWith);
            entity.stickerList.forEach(updateCacheWith);
          }(),
        Member() => () {
            entity.manager.cache[entity.id] = entity;

            updateCacheWith(entity.user);
          }(),
        Message() => () {
            entity.manager.cache[entity.id] = entity;

            updateCacheWith(entity.author);
            entity.mentions.forEach(updateCacheWith);
            updateCacheWith(entity.referencedMessage);
            updateCacheWith(entity.interaction); // ignore: deprecated_member_use_from_same_package
            updateCacheWith(entity.thread);
            updateCacheWith(entity.resolved);
          }(),
        Role() => entity.manager.cache[entity.id] = entity,
        ScheduledEvent() => () {
            entity.manager.cache[entity.id] = entity;

            updateCacheWith(entity.creator);
          }(),
        GuildSticker() => entity.manager.cache[entity.id] = entity,
        Webhook() => () {
            entity.manager.cache[entity.id] = entity;

            updateCacheWith(entity.user);
          }(),
        Sku() => entity.manager.cache[entity.id] = entity,
        Subscription() => entity.manager.cache[entity.id] = entity,

        // "Aggregate" types - objects that contain other (potentially root) objects

        ThreadList(:final threads, :final members) => () {
            threads.forEach(updateCacheWith);
            members.forEach(updateCacheWith);
          }(),
        ThreadMember(:final member) => updateCacheWith(member),
        // ignore: deprecated_member_use_from_same_package
        MessageInteraction(:final user) => updateCacheWith(user),
        ResolvedData(:final users, :final roles, :final members) => () {
            users?.values.forEach(updateCacheWith);
            roles?.values.forEach(updateCacheWith);
            members?.values.forEach(updateCacheWith);
          }(),
        Activity(:final emoji) => updateCacheWith(emoji),
        Interaction(:final data, :final member, :final user, :final message, :final entitlements) => () {
            updateCacheWith(member);
            updateCacheWith(user);
            updateCacheWith(message);
            entitlements.forEach(updateCacheWith);

            if (data case ApplicationCommandInteractionData(:final resolved) || MessageComponentInteractionData(:final resolved)) {
              updateCacheWith(resolved);
            }
          }(),
        Invite(:final inviter, :final targetUser, :final guildScheduledEvent) => () {
            updateCacheWith(inviter);
            updateCacheWith(targetUser);
            updateCacheWith(guildScheduledEvent);
          }(),
        GuildPreview(:final emojiList, :final stickerList) => () {
            emojiList.forEach(updateCacheWith);
            stickerList.forEach(updateCacheWith);
          }(),
        Ban(:final user) => updateCacheWith(user),
        // Don't update cache for serializedSourceGuild since it is populated with some fake data.
        GuildTemplate(:final creator) => updateCacheWith(creator),
        ScheduledEventUser(:final user, :final member) => () {
            updateCacheWith(user);
            updateCacheWith(member);
          }(),
        StickerPack(:final stickers) => stickers.forEach(updateCacheWith),

        // Events

        ReadyEvent(:final user) => updateCacheWith(user),
        ResumedEvent() => null,
        ApplicationCommandPermissionsUpdateEvent(:final permissions) => updateCacheWith(permissions),
        AutoModerationRuleCreateEvent(:final rule) => updateCacheWith(rule),
        AutoModerationRuleUpdateEvent(:final rule) => updateCacheWith(rule),
        AutoModerationRuleDeleteEvent(:final rule) => rule.manager.cache.remove(rule.id),
        AutoModerationActionExecutionEvent() => null,
        ChannelCreateEvent(:final channel) => updateCacheWith(channel),
        ChannelUpdateEvent(:final channel) => updateCacheWith(channel),
        ChannelDeleteEvent(:final channel) => channel.manager.cache.remove(channel.id),
        ThreadCreateEvent(:final thread) => updateCacheWith(thread),
        ThreadUpdateEvent(:final thread) => updateCacheWith(thread),
        ThreadDeleteEvent(:final thread) => thread.manager.cache.remove(thread.id),
        ThreadListSyncEvent(:final threads, :final members) => () {
            threads.forEach(updateCacheWith);
            members.forEach(updateCacheWith);
          }(),
        ThreadMemberUpdateEvent(:final member) => updateCacheWith(member),
        ThreadMembersUpdateEvent(:final addedMembers) => addedMembers?.forEach(updateCacheWith),
        ChannelPinsUpdateEvent() => null,
        UnavailableGuildCreateEvent() => () {
            if (entity
                case GuildCreateEvent(
                  :final guild,
                  :final voiceStates,
                  :final members,
                  :final channels,
                  :final threads,
                  :final presences,
                  :final stageInstances,
                  :final scheduledEvents,
                )) {
              updateCacheWith(guild);
              voiceStates.forEach(updateCacheWith);
              members.forEach(updateCacheWith);
              channels.forEach(updateCacheWith);
              threads.forEach(updateCacheWith);
              presences.forEach(updateCacheWith);
              stageInstances.forEach(updateCacheWith);
              scheduledEvents.forEach(updateCacheWith);
            }
          }(),
        GuildUpdateEvent(:final guild) => updateCacheWith(guild),
        GuildDeleteEvent(:final guild) => guild.manager.cache.remove(guild.id),
        GuildAuditLogCreateEvent(:final entry) => updateCacheWith(entry),
        GuildBanAddEvent(:final user, :final guild) => () {
            guild.members.cache.remove(user.id);
            updateCacheWith(user);
          }(),
        GuildBanRemoveEvent(:final user) => updateCacheWith(user),
        GuildEmojisUpdateEvent(:final emojis, :final guild) => () {
            guild.emojis.cache.clear();
            emojis.forEach(updateCacheWith);
          }(),
        GuildStickersUpdateEvent(:final stickers, :final guild) => () {
            guild.stickers.cache.clear();
            stickers.forEach(updateCacheWith);
          }(),
        GuildIntegrationsUpdateEvent() => null,
        GuildMemberAddEvent(:final member) => updateCacheWith(member),
        GuildMemberRemoveEvent(:final user, :final guild) => () {
            guild.members.cache.remove(user.id);
            updateCacheWith(user);
          }(),
        GuildMemberUpdateEvent(:final member) => updateCacheWith(member),
        GuildMembersChunkEvent(:final members, :final presences) => () {
            members.forEach(updateCacheWith);
            presences?.forEach(updateCacheWith);
          }(),
        GuildRoleCreateEvent(:final role) => updateCacheWith(role),
        GuildRoleUpdateEvent(:final role) => updateCacheWith(role),
        GuildRoleDeleteEvent(:final roleId, :final guild) => guild.roles.cache.remove(roleId),
        GuildScheduledEventCreateEvent(:final event) => updateCacheWith(event),
        GuildScheduledEventUpdateEvent(:final event) => updateCacheWith(event),
        GuildScheduledEventDeleteEvent(:final event) => event.manager.cache.remove(event.id),
        GuildScheduledEventUserAddEvent() => null,
        GuildScheduledEventUserRemoveEvent() => null,
        IntegrationCreateEvent(:final integration) => updateCacheWith(integration),
        IntegrationUpdateEvent(:final integration) => updateCacheWith(integration),
        IntegrationDeleteEvent(:final id, :final guild) => guild.integrations.cache.remove(id),
        InviteCreateEvent(:final invite) => updateCacheWith(invite),
        InviteDeleteEvent() => null,
        MessageCreateEvent(:final message, :final mentions) => () {
            updateCacheWith(message);
            mentions.forEach(updateCacheWith);
          }(),
        MessageUpdateEvent(:final message, :final mentions) => () {
            // We only get a partial message, but we know it invalidates the message currently in the cache. So we remove the cached message.
            message.manager.cache.remove(message.id);
            mentions?.forEach(updateCacheWith);
          }(),
        MessageDeleteEvent(:final id, :final channel) => channel.messages.cache.remove(id),
        MessageBulkDeleteEvent(:final ids, :final channel) => ids.forEach(channel.messages.cache.remove),
        MessageReactionAddEvent(:final emoji, :final member) => () {
            updateCacheWith(emoji);
            updateCacheWith(member);
          }(),
        MessageReactionRemoveEvent(:final emoji) => updateCacheWith(emoji),
        MessageReactionRemoveAllEvent() => null,
        MessageReactionRemoveEmojiEvent() => null,
        PresenceUpdateEvent(:final activities) => activities?.forEach(updateCacheWith),
        TypingStartEvent(:final member) => updateCacheWith(member),
        UserUpdateEvent(:final user) => updateCacheWith(user),
        VoiceStateUpdateEvent(:final state) => updateCacheWith(state),
        VoiceServerUpdateEvent() => null,
        WebhooksUpdateEvent() => null,
        InteractionCreateEvent(:final interaction) => updateCacheWith(interaction),
        StageInstanceCreateEvent(:final instance) => updateCacheWith(instance),
        StageInstanceUpdateEvent(:final instance) => updateCacheWith(instance),
        StageInstanceDeleteEvent(:final instance) => instance.manager.cache.remove(instance.id),
        EntitlementCreateEvent(:final entitlement) => updateCacheWith(entitlement),
        EntitlementUpdateEvent(:final entitlement) => updateCacheWith(entitlement),
        EntitlementDeleteEvent(:final entitlement) => entitlement.manager.cache.remove(entitlement.id),
        MessagePollVoteAddEvent() => null,
        MessagePollVoteRemoveEvent() => null,

        // null and unhandled entity types
        WebhookAuthor() => null,
        UnknownDispatchEvent() => null,
        null => null,
        _ => () {
            assert(() {
              logger
                ..warning('Tried to update cache for ${entity.runtimeType}, but that type was not handled.')
                ..info(
                    'This is a bug, please report it to https://github.com/nyxx-discord/nyxx/issues or on our Discord server. Your client will still work regardless, so you can also ignore this message.');
              return true;
            }());
          }(),
      };
}
