import 'package:nyxx/src/core/audit_logs/audit_log_entry.dart';
import 'package:nyxx/src/core/guild/auto_moderation.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';
import 'package:nyxx/src/internal/http/http_route.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/channel/invite.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/audit_logs/audit_log.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/dm_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/thread_preview_channel.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/channel/guild/voice_channel.dart';
import 'package:nyxx/src/core/guild/ban.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/guild_preview.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/guild/webhook.dart';
import 'package:nyxx/src/core/guild/guild_welcome_screen.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/sticker.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/core/voice/voice_region.dart';
import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/http/http_handler.dart';
import 'package:nyxx/src/internal/http/http_request.dart';
import 'package:nyxx/src/internal/http/http_response.dart';
import 'package:nyxx/src/internal/response_wrapper/thread_list_result_wrapper.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/auto_moderation_builder.dart';
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/forum_thread_builder.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';
import 'package:nyxx/src/utils/builders/guild_event_builder.dart';
import 'package:nyxx/src/utils/builders/member_builder.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';
import 'package:nyxx/src/utils/builders/sticker_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';
import 'package:nyxx/src/utils/utils.dart';

/// Raw access to all http endpoints exposed by nyxx.
/// Allows to execute specific action without any context.
abstract class IHttpEndpoints {
  /// Creates an OAuth2 URL with the specified permissions.
  String getApplicationInviteUrl(Snowflake applicationId, [int? permissions]);

  /// Returns cdn url for given icon hash of role
  String getRoleIconUrl(Snowflake roleId, String iconHash, String format, int size);

  /// Returns cdn url for given [guildId] and [iconHash].
  /// Requires to specify format and size of returned image.
  /// Format can be webp, png. Size should be power of 2, eg. 512, 1024
  String? getGuildIconUrl(Snowflake guildId, String? iconHash, String format, int size);

  /// Returns cdn url for given [guildId] and [splashHash].
  /// Requires to specify format and size of returned image.
  /// Format can be webp, png. Size should be power of 2, eg. 512, 1024
  String? getGuildSplashURL(Snowflake guildId, String? splashHash, String format, int size);

  /// Returns discovery url for given [guildId] and [splashHash]. Allows to additionally specify [format] and [size] of returned image.
  String? getGuildDiscoveryURL(Snowflake guildId, String? splashHash, {String format = "webp", int size = 128});

  /// Returns url to guild widget for given [guildId]. Additionally accepts [style] parameter.
  String getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]);

  /// Returns cnd url for given [guildId] and [bannerHash].
  /// Requires to specify format and size of returned image.
  /// Format can be webp, png. Size should be power of 2, eg. 512, 1024
  String? getGuildBannerUrl(Snowflake guildId, String? bannerHash, {String? format, int? size});

  /// Allows to modify guild emoji.
  Future<BaseGuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId, {String? name, List<Snowflake>? roles, AttachmentBuilder? avatarAttachment});

  /// Removes emoji from given guild
  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId);

  /// Edits role using builder form [role] parameter
  Future<IRole> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role, {String? auditReason});

  /// Deletes from with given [roleId]
  Future<void> deleteRole(Snowflake guildId, Snowflake roleId, {String? auditReason});

  /// Adds role to user
  Future<void> addRoleToUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason});

  /// Fetches [Guild] object from API
  Future<IGuild> fetchGuild(Snowflake guildId, {bool? withCounts = true});

  /// Fetches [IChannel] from API. Channel cas be cast to wanted type using generics
  Future<T> fetchChannel<T>(Snowflake id);

  /// Returns [BaseGuildEmoji] for given [emojiId]
  Future<IBaseGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId);

  /// Fetches a [IGuildWelcomeScreen] from the given [guildId]
  Future<IGuildWelcomeScreen> fetchGuildWelcomeScreen(Snowflake guildId);

  /// Creates emoji in given guild
  Future<IBaseGuildEmoji> createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment});

  /// Fetches a [IUser] that created the emoji from the given [emojiId]
  Future<IUser> fetchEmojiCreator(Snowflake guildId, Snowflake emojiId);

  /// Returns how many user will be pruned in prune operation
  Future<int> guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles});

  /// Executes actual prune action, returning how many users were pruned.
  Future<int> guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason});

  /// Get all guild bans.
  Stream<IBan> getGuildBans(Snowflake guildId, {int limit = 1000, Snowflake? before, Snowflake? after});

  Future<void> modifyCurrentMember(Snowflake guildId, {String? nick});

  /// Get [IBan] object for given [bannedUserId]
  Future<IBan> getGuildBan(Snowflake guildId, Snowflake bannedUserId);

  /// Changes guild owner of guild from bot to [member].
  /// Bot needs to be owner of guild to use that endpoint.
  Future<IGuild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason});

  /// Leaves guild with given id
  Future<void> leaveGuild(Snowflake guildId);

  /// Creates a new guild.
  Future<IGuild> createGuild(GuildBuilder builder);

  /// Returns list of all guild invites
  Stream<IInvite> fetchGuildInvites(Snowflake guildId);

  /// Creates an activity invite
  Future<IInvite> createVoiceActivityInvite(Snowflake activityId, Snowflake channelId, {int? maxAge, int? maxUses});

  /// Fetches audit logs of guild
  Future<IAuditLog> fetchAuditLogs(Snowflake guildId, {Snowflake? userId, AuditLogEntryType? auditType, Snowflake? before, int? limit});

  /// Creates new role
  Future<IRole> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder, {String? auditReason});

  /// Returns list of all voice regions that guild has access to
  Stream<IVoiceRegion> fetchGuildVoiceRegions(Snowflake guildId);

  /// Moves guild channel in hierachy.
  Future<void> moveGuildChannel(Snowflake guildId, Snowflake channelId, int position, {String? auditReason});

  /// Ban user with given id
  Future<void> guildBan(Snowflake guildId, Snowflake userId, {int deleteMessageDays = 0, String? auditReason});

  /// Kick user from guild
  Future<void> guildKick(Snowflake guildId, Snowflake userId, {String? auditReason});

  /// Unban user with given id
  Future<void> guildUnban(Snowflake guildId, Snowflake userId);

  /// Allows to edit basic guild properties
  Future<IGuild> editGuild(Snowflake guildId, GuildBuilder builder, {String? auditReason});

  /// Fetches [Member] object from guild
  Future<IMember> fetchGuildMember(Snowflake guildId, Snowflake memberId);

  /// Fetches list of members from guild.
  /// Requires GUILD_MEMBERS intent to work properly.
  Stream<IMember> fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after});

  /// Searches guild for user with [query] parameter
  /// Requires GUILD_MEMBERS intent to work properly.
  Stream<IMember> searchGuildMembers(Snowflake guildId, String query, {int limit = 1});

  /// Returns all [Webhook]s in given channel
  Stream<IWebhook> fetchChannelWebhooks(Snowflake channelId);

  /// Deletes guild. Requires bot to be owner of guild
  Future<void> deleteGuild(Snowflake guildId);

  /// Returns all roles of guild
  Stream<IRole> fetchGuildRoles(Snowflake guildId);

  /// Returns url to user avatar
  String userAvatarURL(Snowflake userId, String? avatarHash, int discriminator, {String format = "webp", int size = 128});

  /// Returns url to member avatar url
  String memberAvatarURL(Snowflake memberId, Snowflake guildId, String avatarHash, {String format = "webp"});

  /// Fetches [User] object for given [userId]
  Future<IUser> fetchUser(Snowflake userId);

  /// "Edits" guild member. Allows to manipulate other guild users.
  Future<void> editGuildMember(Snowflake guildId, Snowflake memberId, {required MemberBuilder builder, String? auditReason});

  /// Removes role from user
  Future<void> removeRoleFromUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason});

  /// Returns invites for given channel. Includes additional metadata.
  Stream<IInviteWithMeta> fetchChannelInvites(Snowflake channelId);

  /// Allows to edit permission for channel
  Future<void> editChannelPermissions(Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason});

  /// Allows to edit permission of channel (channel overrides)
  Future<void> editChannelPermissionOverrides(Snowflake channelId, PermissionOverrideBuilder permissionBuilder, {String? auditReason});

  /// Deletes permission overrides for given entity [id]
  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id, {String? auditReason});

  /// Creates new invite for given [channelId]
  Future<IInvite> createInvite(Snowflake channelId, {int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason});

  /// Sends message in channel with given [channelId] using [builder]
  Future<IMessage> sendMessage(Snowflake channelId, MessageBuilder builder);

  /// Fetches single message with given [messageId]
  Future<IMessage> fetchMessage(Snowflake channelId, Snowflake messageId);

  /// Bulk removes messages in given [channelId].
  Future<void> bulkRemoveMessages(Snowflake channelId, Iterable<SnowflakeEntity> messagesIds);

  /// Downloads messages in given channel.
  Stream<IMessage> downloadMessages(Snowflake channelId, {int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around});

  /// Crates new webhook
  Future<IWebhook> createWebhook(Snowflake channelId, String name, {AttachmentBuilder? avatarAttachment, String? auditReason});

  /// Returns all pinned messages in channel
  Stream<IMessage> fetchPinnedMessages(Snowflake channelId);

  /// Triggers typing indicator in channel
  Future<void> triggerTyping(Snowflake channelId);

  /// Cross posts message in new channel to all subsribed channels
  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId);

  /// Sends message and creates new thread in one action.
  Future<IThreadPreviewChannel> createThreadWithMessage(Snowflake channelId, Snowflake messageId, ThreadBuilder builder);

  /// Creates new thread.
  Future<IThreadPreviewChannel> createThread(Snowflake channelId, ThreadBuilder builder);

  /// Returns all member of given thread
  /// Returns [IThreadMemberWithMember] when [withMembers] set to true
  Stream<IThreadMember> fetchThreadMembers(Snowflake channelId, Snowflake guildId, {bool withMembers = false, Snowflake? after, int limit = 100});

  /// Fetches single thread member
  /// Returns [IThreadMemberWithMember] when [withMembers] set to true
  Future<IThreadMember> fetchThreadMember(Snowflake channelId, Snowflake guildId, Snowflake memberId, {bool withMembers = false});

  /// Joins thread with given id
  Future<void> joinThread(Snowflake channelId);

  /// Adds member to thread given bot has sufficient permissions
  Future<void> addThreadMember(Snowflake channelId, Snowflake userId);

  /// Leave thread with given id
  Future<void> leaveThread(Snowflake channelId);

  /// Removes member from thread given bot has sufficient permissions
  Future<void> removeThreadMember(Snowflake channelId, Snowflake userId);

  /// Returns all public archived thread in given channel
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all private archived thread in given channel
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all joined private archived thread in given channel
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all active threads in the guild, including public and private threads.
  /// Threads are ordered by their id, in descending order.
  Future<IThreadListResultWrapper> fetchGuildActiveThreads(Snowflake guildId);

  /// Removes all embeds from given message
  @Deprecated("Use MessageBuilder flags")
  Future<IMessage> suppressMessageEmbeds(Snowflake channelId, Snowflake messageId);

  /// Edits message with given id using [builder]
  Future<IMessage> editMessage(Snowflake channelId, Snowflake messageId, MessageBuilder builder);

  /// Edits message sent by webhook
  Future<IMessage> editWebhookMessage(Snowflake webhookId, Snowflake messageId, MessageBuilder builder, {String? token, Snowflake? threadId});

  /// Creates reaction with given [emoji] on given message
  Future<void> createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes the bot's reaction with a given [emoji] from message
  Future<void> deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes all reactions of given user from message.
  Future<void> deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId);

  /// Deletes all reactions on given message
  Future<void> deleteMessageAllReactions(Snowflake channelId, Snowflake messageId);

  /// Fetches all reactions with a given emoji on a message
  Stream<IUser> fetchMessageReactionUsers(
    Snowflake channelId,
    Snowflake messageId,
    IEmoji emoji, {
    Snowflake? after,
    int? limit,
  });

  /// Deletes all reactions with a given emoji on a message
  Future<void> deleteMessageReactions(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes message from given channel
  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId, {String? auditReason});

  /// Deletes message sent by webhook
  Future<void> deleteWebhookMessage(Snowflake webhookId, Snowflake messageId, {String? auditReason, String? token, Snowflake? threadId});

  /// Pins message in channel
  Future<void> pinMessage(Snowflake channelId, Snowflake messageId);

  /// Unpins message from channel
  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId);

  /// Edits self user.
  Future<IUser> editSelfUser({String? username, AttachmentBuilder? avatarAttachment});

  /// Deletes invite with given [code]
  Future<void> deleteInvite(String code, {String? auditReason});

  /// Deletes webhook with given [id] using bot permissions or [token] if supplied
  Future<void> deleteWebhook(Snowflake id, {String token = "", String? auditReason});

  Future<IWebhook> editWebhook(Snowflake webhookId,
      {String token = "", String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason});

  /// Executes [Webhook] -- sends message using [Webhook]
  /// To execute webhook in thread use [threadId] parameter.
  /// Webhooks can have overridden [avatarUrl] and [username] per each
  /// execution.
  ///
  /// If [wait] is set to true -- request will return resulting message.
  Future<IMessage?> executeWebhook(Snowflake webhookId, MessageBuilder builder,
      {String token = "", bool wait = true, String? avatarUrl, String? username, Snowflake? threadId, String? threadName});

  /// Fetches webhook using its [id] and optionally [token].
  /// If [token] is specified it will be used to fetch webhook data.
  /// If not authenticated or missing permissions
  /// for given webhook token can be used.
  Future<IWebhook> fetchWebhook(Snowflake id, {String token = ""});

  /// Fetches invite based on specified [code]
  Future<IInvite> fetchInvite(String code);

  /// Returns url for sticker.
  String stickerUrl(Snowflake stickerId, String extension);

  /// Returns url for given [emojiId]
  String emojiUrl(Snowflake emojiId);

  /// Creates and returns [DMChannel] for user with given [userId].
  Future<IDMChannel> createDMChannel(Snowflake userId);

  /// Used to send a request including standard bot authentication.
  Future<IHttpResponse> sendRawRequest(IHttpRoute route, String method,
      {dynamic body,
      Map<String, dynamic>? headers,
      List<AttachmentBuilder> files = const [],
      Map<String, dynamic>? queryParams,
      bool auth = false,
      bool rateLimit = true});

  /// Fetches preview of guild
  Future<IGuildPreview> fetchGuildPreview(Snowflake guildId);

  /// Allows to create guild channel.
  Future<IChannel> createGuildChannel(Snowflake guildId, ChannelBuilder channelBuilder);

  /// Deletes guild channel
  Future<void> deleteChannel(Snowflake channelId);

  /// Gets the stage instance associated with the Stage channel, if it exists.
  Future<IStageChannelInstance> getStageChannelInstance(Snowflake channelId);

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance(Snowflake channelId);

  /// Creates a new Stage instance associated to a Stage channel.
  Future<IStageChannelInstance> createStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel});

  /// Updates fields of an existing Stage instance.
  Future<IStageChannelInstance> updateStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel});

  /// Allows to edit guild channel. Resulting updated channel can by cast using generics
  Future<T> editGuildChannel<T extends IGuildChannel>(Snowflake channelId, ChannelBuilder builder, {String? auditReason});

  /// Allows editing thread channel.
  Future<ThreadChannel> editThreadChannel(Snowflake channelId, ThreadBuilder builder, {String auditReason});

  /// Returns single nitro sticker
  Future<IStandardSticker> getSticker(Snowflake id);

  /// Returns all nitro sticker packs
  Stream<IStickerPack> listNitroStickerPacks();

  /// Fetches all [GuildSticker]s in given [Guild]
  Stream<IGuildSticker> fetchGuildStickers(Snowflake guildId);

  /// Fetches [GuildSticker]
  Future<IGuildSticker> fetchGuildSticker(Snowflake guildId, Snowflake stickerId);

  /// Creates [GuildSticker] in given [Guild]
  Future<IGuildSticker> createGuildSticker(Snowflake guildId, StickerBuilder builder);

  /// Edits [GuildSticker]. Only allows to update sticker metadata
  Future<IGuildSticker> editGuildSticker(Snowflake guildId, Snowflake stickerId, StickerBuilder builder);

  /// Deletes [GuildSticker] for [Guild]
  Future<void> deleteGuildSticker(Snowflake guildId, Snowflake stickerId);

  /// Returns url of user banner
  String? userBannerURL(Snowflake userId, String? hash, {String? format, int? size});

  Stream<GuildEvent> fetchGuildEvents(Snowflake guildId, {bool withUserCount = false});

  Future<GuildEvent> createGuildEvent(Snowflake guildId, GuildEventBuilder builder);

  Future<GuildEvent> fetchGuildEvent(Snowflake guildId, Snowflake guildEventId);

  Future<GuildEvent> editGuildEvent(Snowflake guildId, Snowflake guildEventId, GuildEventBuilder builder);

  Future<void> deleteGuildEvent(Snowflake guildId, Snowflake guildEventId);

  Stream<GuildEventUser> fetchGuildEventUsers(Snowflake guildId, Snowflake guildEventId,
      {int limit = 100, bool withMember = false, Snowflake? before, Snowflake? after});

  Future<IThreadChannel> startForumThread(Snowflake channelId, ForumThreadBuilder builder);

  Stream<IAutoModerationRule> fetchAutoModerationRules(Snowflake guildId);

  Future<IAutoModerationRule> fetchAutoModerationRule(Snowflake guildId, Snowflake ruleId);

  Future<IAutoModerationRule> createAutoModerationRule(Snowflake guildId, AutoModerationRuleBuilder builder, {String? auditReason});

  Future<IAutoModerationRule> editAutoModerationRule(Snowflake guildId, Snowflake ruleId, AutoModerationRuleBuilder builder, {String? auditReason});

  Future<void> deleteAutoModerationRule(Snowflake guildId, Snowflake ruleId, {String? auditReason});
}

class HttpEndpoints implements IHttpEndpoints {
  late final HttpHandler httpHandler;
  final INyxx client;

  /// Creates an instance of [HttpEndpoints]
  HttpEndpoints(this.client) {
    httpHandler = client.httpHandler;
  }

  Future<HttpResponseSuccess> executeSafe(HttpRequest request) async {
    final response = await httpHandler.execute(request);

    if (response is! HttpResponseSuccess) {
      return Future.error(response, StackTrace.current);
    }

    return response;
  }

  @override
  String getApplicationInviteUrl(Snowflake applicationId, [int? permissions]) {
    var baseLink = "https://${Constants.host}/oauth2/authorize?client_id=${applicationId.toString()}&scope=bot%20applications.commands";

    if (permissions != null) {
      baseLink += "&permissions=$permissions";
    }

    return baseLink;
  }

  @override
  String? getGuildIconUrl(Snowflake guildId, String? iconHash, String format, int size) {
    if (iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/icons/$guildId/$iconHash.$format?size=$size";
    }

    return null;
  }

  @override
  String? getGuildSplashURL(Snowflake guildId, String? splashHash, String format, int size) {
    if (splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/splashes/$guildId/$splashHash.$format?size=$size";
    }

    return null;
  }

  @override
  String? getGuildDiscoveryURL(Snowflake guildId, String? splashHash, {String format = "webp", int size = 128}) {
    if (splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/discovery-splashes/$guildId/$splashHash.$format?size=$size";
    }

    return null;
  }

  @override
  String? getGuildBannerUrl(Snowflake guildId, String? bannerHash, {String? format, int? size}) {
    if (bannerHash != null) {
      var url = "${Constants.cdnUrl}/banners/$guildId/$bannerHash.";
      if (format == null && bannerHash.startsWith('a_')) {
        url += "gif";
      } else {
        url += format ?? "webp";
      }

      if (size != null) {
        url += "?size=$size";
      }

      return url;
    }
    return null;
  }

  @override
  String getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]) => "https://cdn.${Constants.cdnHost}/guilds/$guildId/widget.png?style=$style";

  @override
  Future<GuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId, {String? name, List<Snowflake>? roles, AttachmentBuilder? avatarAttachment}) async {
    if (name == null && roles == null) {
      return throw ArgumentError("Both name and roles fields cannot be null");
    }

    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString()).toList(),
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64()
    };

    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..emojis(id: emojiId.toString()),
        method: "PATCH",
        body: body));

    return GuildEmoji(client, response.jsonBody as RawApiMap, guildId);
  }

  @override
  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..emojis(id: emojiId.toString()),
      method: "DELETE"));

  @override
  Future<Role> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role, {String? auditReason}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..roles(id: roleId.toString()),
        method: "PATCH",
        body: role.build(),
        auditLog: auditReason));

    return Role(client, response.jsonBody as RawApiMap, guildId);
  }

  @override
  Future<IThreadChannel> startForumThread(Snowflake channelId, ForumThreadBuilder builder) async {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..threads(),
        method: "POST",
        body: builder.build(),
      ),
    );

    return ThreadChannel(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> deleteRole(Snowflake guildId, Snowflake roleId, {String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..roles(id: roleId.toString()),
      method: "DELETE",
      auditLog: auditReason));

  @override
  Future<void> addRoleToUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..members(id: userId.toString())
        ..roles(id: roleId.toString()),
      method: "PUT",
      auditLog: auditReason));

  @override
  Future<IGuild> fetchGuild(Snowflake guildId, {bool? withCounts = true}) async {
    final response =
        await executeSafe(BasicRequest(HttpRoute()..guilds(id: guildId.toString()), queryParams: {"with_counts": (withCounts ?? true).toString()}));

    return Guild(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<T> fetchChannel<T>(Snowflake id) async {
    final response = await executeSafe(BasicRequest(HttpRoute()..channels(id: id.toString())));

    final raw = response.jsonBody as RawApiMap;
    return Channel.deserialize(client, raw) as T;
  }

  @override
  Future<IBaseGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: emojiId.toString())));

    return GuildEmoji(client, response.jsonBody as RawApiMap, guildId);
  }

  @override
  Future<IGuildWelcomeScreen> fetchGuildWelcomeScreen(Snowflake guildId) async {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..welcomeScreen(),
    ));

    return GuildWelcomeScreen(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IBaseGuildEmoji> createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment}) async {
    final body = <String, dynamic>{
      "name": name,
      if (roles != null) "roles": roles.map((r) => r.id.toString()).toList(),
      if (emojiAttachment != null) "image": emojiAttachment.getBase64()
    };

    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..emojis(),
        method: "POST",
        body: body));

    return GuildEmoji(client, response.jsonBody as RawApiMap, guildId);
  }

  @override
  Future<IUser> fetchEmojiCreator(Snowflake guildId, Snowflake emojiId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..guilds(id: guildId.toString())
      ..emojis(id: emojiId.toString())));

    if (response.jsonBody["managed"] as bool) {
      throw ArgumentError("Emoji is managed");
    }

    if (response.jsonBody["user"] == null) {
      throw ArgumentError("Could not find user creator, make sure you have the correct permissions");
    }

    final user = User(client, response.jsonBody["user"] as RawApiMap);

    if (client.cacheOptions.userCachePolicyLocation.http) {
      return client.users.putIfAbsent(user.id, () => user);
    }

    return user;
  }

  @override
  Future<int> guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..prune(),
        queryParams: {"days": days.toString(), if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())}));

    return response.jsonBody["pruned"] as int;
  }

  @override
  Future<int> guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..prune(),
        method: "POST",
        auditLog: auditReason,
        queryParams: {"days": days.toString()},
        body: {if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())}));

    return response.jsonBody["pruned"] as int;
  }

  @override
  Stream<IBan> getGuildBans(Snowflake guildId, {int limit = 1000, Snowflake? before, Snowflake? after}) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..bans(),
      queryParams: {
        "limit": limit,
        if (before != null) "before": before,
        if (after != null) "after": after,
      },
    ));

    for (final obj in response.jsonBody) {
      yield Ban(obj as RawApiMap, client);
    }
  }

  @override
  Future<void> modifyCurrentMember(Snowflake guildId, {String? nick}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..members(id: "@me")
        ..nick(),
      method: "PATCH",
      body: {if (nick != null) "nick": nick}));

  @override
  Future<IBan> getGuildBan(Snowflake guildId, Snowflake bannedUserId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..guilds(id: guildId.toString())
      ..bans(id: bannedUserId.toString())));

    return Ban(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IGuild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason}) async {
    final response = await executeSafe(BasicRequest(
      HttpRoute()..guilds(id: guildId.toString()),
      method: "PATCH",
      auditLog: auditReason,
      body: {
        "owner_id": member.id.toString(),
      },
    ));

    return Guild(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> leaveGuild(Snowflake guildId) async => executeSafe(BasicRequest(
      HttpRoute()
        ..users(id: "@me")
        ..guilds(id: guildId.toString()),
      method: "DELETE"));

  @override
  Future<IGuild> createGuild(GuildBuilder builder) async {
    final response = await executeSafe(BasicRequest(HttpRoute()..guilds(), method: "POST", body: builder.build()));

    final guild = Guild(client, response.jsonBody as RawApiMap);
    client.guilds[guild.id] = guild;
    return guild;
  }

  @override
  Stream<IInvite> fetchGuildInvites(Snowflake guildId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..invites(),
    ));

    for (final raw in response.jsonBody) {
      yield Invite(raw as RawApiMap, client);
    }
  }

  @override
  Future<IInvite> createVoiceActivityInvite(Snowflake activityId, Snowflake channelId, {int? maxAge, int? maxUses}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..invites(),
        method: "POST",
        body: {
          "max_age": maxAge ?? 0,
          "max_uses": maxUses ?? 0,
          "target_application_id": activityId.toString(),
          "target_type": 2,
        }));

    return Invite(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IAuditLog> fetchAuditLogs(Snowflake guildId, {Snowflake? userId, AuditLogEntryType? auditType, Snowflake? before, int? limit}) async {
    final queryParams = <String, dynamic>{
      if (userId != null) "user_id": userId.toString(),
      if (auditType != null) "action_type": auditType.value.toString(),
      if (before != null) "before": before.toString(),
      if (limit != null) "limit": limit.toString()
    };

    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..auditlogs(),
        queryParams: queryParams));

    return AuditLog(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IRole> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder, {String? auditReason}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..roles(),
        method: "POST",
        auditLog: auditReason,
        body: roleBuilder.build()));

    return Role(client, response.jsonBody as RawApiMap, guildId);
  }

  @override
  Stream<IVoiceRegion> fetchGuildVoiceRegions(Snowflake guildId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..regions(),
    ));

    for (final raw in response.jsonBody) {
      yield VoiceRegion(raw as RawApiMap);
    }
  }

  @override
  Future<void> moveGuildChannel(Snowflake guildId, Snowflake channelId, int position, {String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..channels(),
      method: "PATCH",
      auditLog: auditReason,
      body: {"id": channelId.toString(), "position": position}));

  @override
  Future<void> guildBan(Snowflake guildId, Snowflake userId, {int deleteMessageDays = 0, String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..bans(id: userId.toString()),
      method: "PUT",
      auditLog: auditReason,
      body: {"delete-message-days": deleteMessageDays}));

  @override
  Future<void> guildKick(Snowflake guildId, Snowflake userId, {String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..members(id: userId.toString()),
      method: "DELETE",
      auditLog: auditReason));

  @override
  Future<void> guildUnban(Snowflake guildId, Snowflake userId) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..bans(id: userId.toString()),
      method: "DELETE"));

  @override
  Future<IGuild> editGuild(Snowflake guildId, GuildBuilder builder, {String? auditReason}) async {
    final response =
        await executeSafe(BasicRequest(HttpRoute()..guilds(id: guildId.toString()), method: "PATCH", auditLog: auditReason, body: builder.build()));

    return Guild(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IMember> fetchGuildMember(Snowflake guildId, Snowflake memberId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: memberId.toString())));

    final member = Member(client, response.jsonBody as RawApiMap, guildId);

    if (client.cacheOptions.memberCachePolicyLocation.http && client.cacheOptions.memberCachePolicy.canCache(member)) {
      member.guild.getFromCache()?.members[member.id] = member;
    }

    return member;
  }

  @override
  Stream<IMember> fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after}) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..members(),
      queryParams: {"limit": limit.toString(), if (after != null) "after": after.toString()},
    ));

    for (final rawMember in response.jsonBody as RawApiList) {
      final member = Member(client, rawMember as RawApiMap, guildId);

      if (client.cacheOptions.memberCachePolicyLocation.http && client.cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      yield member;
    }
  }

  @override
  Stream<IMember> searchGuildMembers(Snowflake guildId, String query, {int limit = 1}) async* {
    if (query.isEmpty) {
      throw ArgumentError("`query` parameter cannot be empty. If you want to request all members use `fetchGuildMembers`");
    }

    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..members()
        ..search(),
      queryParams: {"query": query, "limit": limit.toString()},
    ));

    for (final RawApiMap memberData in response.jsonBody) {
      final member = Member(client, memberData, guildId);

      if (client.cacheOptions.memberCachePolicyLocation.http && client.cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      yield member;
    }
  }

  @override
  Stream<IWebhook> fetchChannelWebhooks(Snowflake channelId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..webhooks(),
    ));

    for (final raw in response.jsonBody) {
      yield Webhook(raw as RawApiMap, client);
    }
  }

  @override
  Future<void> deleteGuild(Snowflake guildId) async => executeSafe(BasicRequest(HttpRoute()..guilds(id: guildId.toString()), method: "DELETE"));

  @override
  Stream<IRole> fetchGuildRoles(Snowflake guildId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..roles(),
    ));

    for (final rawRole in response.jsonBody) {
      yield Role(client, rawRole as RawApiMap, guildId);
    }
  }

  @override
  String userAvatarURL(Snowflake userId, String? avatarHash, int discriminator, {String format = "webp", int size = 128}) {
    if (avatarHash != null) {
      return "https://cdn.${Constants.cdnHost}/avatars/$userId/$avatarHash.$format?size=$size";
    }

    return "https://cdn.${Constants.cdnHost}/embed/avatars/${discriminator % 5}.png?size=$size";
  }

  @override
  Future<IUser> fetchUser(Snowflake userId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()..users(id: userId.toString())));

    final user = User(client, response.jsonBody as RawApiMap);

    if (client.cacheOptions.userCachePolicyLocation.http) {
      client.users[user.id] = user;
    }

    return user;
  }

  @override
  Future<void> editGuildMember(Snowflake guildId, Snowflake memberId, {required MemberBuilder builder, String? auditReason}) {
    return executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..members(id: memberId.toString()),
        method: "PATCH",
        auditLog: auditReason,
        body: builder.build()));
  }

  @override
  Future<void> removeRoleFromUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..members(id: userId.toString())
        ..roles(id: roleId.toString()),
      method: "DELETE",
      auditLog: auditReason));

  @override
  Stream<IInviteWithMeta> fetchChannelInvites(Snowflake channelId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..invites(),
    ));

    final bodyValues = response.jsonBody;

    for (final val in bodyValues) {
      yield InviteWithMeta(val as RawApiMap, client);
    }
  }

  @override
  Future<void> editChannelPermissions(Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) async {
    await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..permissions(id: entity.id.toString()),
        method: "PUT",
        body: {"type": entity is IRole ? 0 : 1, ...perms.build()},
        auditLog: auditReason));
  }

  @override
  Future<void> editChannelPermissionOverrides(Snowflake channelId, PermissionOverrideBuilder permissionBuilder, {String? auditReason}) async {
    await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..permissions(id: permissionBuilder.id.toString()),
        method: "PUT",
        body: permissionBuilder.build(),
        auditLog: auditReason));
  }

  @override
  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id, {String? auditReason}) async => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..permissions(id: id.toString()),
      method: "PUT",
      auditLog: auditReason));

  @override
  Future<IInviteWithMeta> createInvite(Snowflake channelId, {int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) async {
    final body = {
      if (maxAge != null) "max_age": maxAge,
      if (maxUses != null) "max_uses": maxUses,
      if (temporary != null) "temporary": temporary,
      if (unique != null) "unique": unique,
    };

    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..invites(),
        method: "POST",
        body: body,
        auditLog: auditReason));

    return InviteWithMeta(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IMessage> sendMessage(Snowflake channelId, MessageBuilder builder) async {
    if (!builder.canBeUsedAsNewMessage()) {
      throw ArgumentError("Cannot sent message when MessageBuilder doesn't have set either content, embed or files");
    }

    HttpResponseSuccess response;
    if (builder.hasFiles()) {
      response = await executeSafe(MultipartRequest(
          HttpRoute()
            ..channels(id: channelId.toString())
            ..messages(),
          builder.getMappedFiles().toList(),
          method: "POST",
          fields: builder.build(client.options.allowedMentions)));
    } else {
      response = await executeSafe(BasicRequest(
          HttpRoute()
            ..channels(id: channelId.toString())
            ..messages(),
          body: builder.build(client.options.allowedMentions),
          method: "POST"));
    }

    return Message(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> fetchMessage(Snowflake channelId, Snowflake messageId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: messageId.toString())));

    return Message(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> bulkRemoveMessages(Snowflake channelId, Iterable<SnowflakeEntity> messagesIds) async {
    await for (final chunk in messagesIds.toList().chunk(90)) {
      await executeSafe(BasicRequest(
          HttpRoute()
            ..channels(id: channelId.toString())
            ..messages()
            ..bulkdelete(),
          method: "POST",
          body: {"messages": chunk.map((f) => f.id.toString()).toList()}));
    }
  }

  @override
  Stream<IMessage> downloadMessages(Snowflake channelId, {int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around}) async* {
    final queryParams = {
      "limit": limit.toString(),
      if (after != null) "after": after.toString(),
      if (before != null) "before": before.toString(),
      if (around != null) "around": around.toString()
    };

    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(),
      queryParams: queryParams,
    ));

    for (final val in response.jsonBody) {
      yield Message(client, val as RawApiMap);
    }
  }

  @override
  Future<T> editGuildChannel<T extends IGuildChannel>(Snowflake channelId, ChannelBuilder builder, {String? auditReason}) async {
    final response =
        await executeSafe(BasicRequest(HttpRoute()..channels(id: channelId.toString()), method: "PATCH", body: builder.build(), auditLog: auditReason));

    return Channel.deserialize(client, response.jsonBody as RawApiMap) as T;
  }

  @override
  Future<IWebhook> createWebhook(Snowflake channelId, String name, {AttachmentBuilder? avatarAttachment, String? auditReason}) async {
    if (name.isEmpty || name.length > 80) {
      throw ArgumentError("Webhook name cannot be shorter than 1 character and longer than 80 characters");
    }

    final body = <String, dynamic>{
      "name": name,
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64(),
    };

    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..webhooks(),
        method: "POST",
        body: body,
        auditLog: auditReason));

    return Webhook(response.jsonBody as RawApiMap, client);
  }

  @override
  Stream<IMessage> fetchPinnedMessages(Snowflake channelId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..pins(),
    ));

    for (final val in response.jsonBody as RawApiList) {
      yield Message(client, val as RawApiMap);
    }
  }

  @override
  Future<void> triggerTyping(Snowflake channelId) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..typing(),
      method: "POST"));

  @override
  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId) async => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString())
        ..crosspost(),
      method: "POST"));

  @override
  Future<IThreadPreviewChannel> createThreadWithMessage(Snowflake channelId, Snowflake messageId, ThreadBuilder builder) async {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..messages(id: messageId.toString())
          ..threads(),
        method: "POST",
        body: builder.build(),
      ),
    );

    return ThreadPreviewChannel(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IThreadPreviewChannel> createThread(Snowflake channelId, ThreadBuilder builder) async {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..threads(),
        method: "POST",
        body: builder.build(),
      ),
    );

    return ThreadPreviewChannel(client, response.jsonBody as RawApiMap);
  }

  @override
  Stream<IThreadMember> fetchThreadMembers(Snowflake channelId, Snowflake guildId, {bool withMembers = false, Snowflake? after, int limit = 100}) async* {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..threadMembers(),
        queryParams: {'with_member': withMembers, if (withMembers) 'limit': limit, if (withMembers && after != null) 'after': after.toString()}));

    final guild = GuildCacheable(client, guildId);

    for (final rawThreadMember in response.jsonBody as RawApiList) {
      yield withMembers ? ThreadMemberWithMember(client, rawThreadMember as RawApiMap, guild) : ThreadMember(client, rawThreadMember as RawApiMap, guild);
    }
  }

  @override
  Future<IMessage> suppressMessageEmbeds(Snowflake channelId, Snowflake messageId) async {
    final body = <String, dynamic>{"flags": 1 << 2};

    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..messages(id: messageId.toString()),
        method: "PATCH",
        body: body));

    return Message(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> editMessage(Snowflake channelId, Snowflake messageId, MessageBuilder builder) async {
    if (!builder.canBeUsedAsNewMessage()) {
      throw ArgumentError("Cannot edit a message to have neither content nor embeds");
    }

    HttpResponseSuccess response;
    if (builder.hasFiles()) {
      response = await executeSafe(MultipartRequest(
          HttpRoute()
            ..channels(id: channelId.toString())
            ..messages(id: messageId.toString()),
          builder.getMappedFiles().toList(),
          method: "PATCH",
          fields: builder.build(client.options.allowedMentions)));
    } else {
      response = await executeSafe(BasicRequest(
          HttpRoute()
            ..channels(id: channelId.toString())
            ..messages(id: messageId.toString()),
          body: builder.build(client.options.allowedMentions),
          method: "PATCH"));
    }

    return Message(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> editWebhookMessage(Snowflake webhookId, Snowflake messageId, MessageBuilder builder, {String? token, Snowflake? threadId}) async {
    HttpResponseSuccess response;
    if (builder.hasFiles()) {
      response = await executeSafe(MultipartRequest(
          HttpRoute()
            ..webhooks(id: webhookId.toString(), token: token?.toString())
            ..messages(id: messageId.toString()),
          builder.getMappedFiles().toList(),
          method: "PATCH",
          fields: builder.build(client.options.allowedMentions),
          queryParams: {if (threadId != null) 'thread_id': threadId}));
    } else {
      response = await executeSafe(BasicRequest(
          HttpRoute()
            ..webhooks(id: webhookId.toString(), token: token?.toString())
            ..messages(id: messageId.toString()),
          body: builder.build(client.options.allowedMentions),
          method: "PATCH",
          queryParams: {if (threadId != null) 'thread_id': threadId}));
    }

    return Message(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString())
        ..reactions(emoji: emoji.encodeForAPI(), userId: "@me"),
      method: "PUT"));

  @override
  Future<void> deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString())
        ..reactions(emoji: emoji.encodeForAPI(), userId: "@me"),
      method: "DELETE"));

  @override
  Future<void> deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString())
        ..reactions(emoji: emoji.encodeForAPI(), userId: userId.toString()),
      method: "DELETE"));

  @override
  Future<void> deleteMessageAllReactions(Snowflake channelId, Snowflake messageId) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString())
        ..reactions(),
      method: "DELETE"));

  @override
  Stream<IUser> fetchMessageReactionUsers(
    Snowflake channelId,
    Snowflake messageId,
    IEmoji emoji, {
    Snowflake? after,
    int? limit,
  }) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString())
        ..reactions(emoji: emoji.encodeForAPI()),
      queryParams: {
        if (after != null) "after": after.toString(),
        if (limit != null) "limit": limit,
      },
    ));

    for (final rawUser in (response.jsonBody as RawApiList).cast<RawApiMap>()) {
      yield User(client, rawUser);
    }
  }

  @override
  Future<void> deleteMessageReactions(Snowflake channelId, Snowflake messageId, IEmoji emoji) => executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..messages(id: messageId.toString())
          ..reactions(emoji: emoji.encodeForAPI()),
        method: "DELETE",
      ));

  @override
  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId, {String? auditReason}) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..messages(id: messageId.toString()),
      method: "DELETE",
      auditLog: auditReason));

  @override
  Future<void> deleteWebhookMessage(Snowflake webhookId, Snowflake messageId, {String? auditReason, String? token, Snowflake? threadId}) =>
      executeSafe(BasicRequest(
          HttpRoute()
            ..webhooks(id: webhookId.toString(), token: token?.toString())
            ..messages(id: messageId.toString()),
          method: "DELETE",
          auditLog: auditReason,
          queryParams: {if (threadId != null) 'thread_id': threadId}));

  @override
  Future<void> pinMessage(Snowflake channelId, Snowflake messageId) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..pins(id: messageId.toString()),
      method: "PUT"));

  @override
  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId) => executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..pins(id: messageId.toString()),
      method: "DELETE"));

  @override
  Future<IUser> editSelfUser({String? username, AttachmentBuilder? avatarAttachment}) async {
    final body = <String, dynamic>{
      if (username != null) "username": username,
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64(),
    };

    final response = await executeSafe(BasicRequest(HttpRoute()..users(id: "@me"), method: "PATCH", body: body));

    return User(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> deleteInvite(String code, {String? auditReason}) async =>
      executeSafe(BasicRequest(HttpRoute()..invites(id: code.toString()), method: "DELETE", auditLog: auditReason));

  @override
  Future<void> deleteWebhook(Snowflake id, {String token = "", String? auditReason}) => executeSafe(
      BasicRequest(HttpRoute()..webhooks(id: id.toString(), token: token.toString()), method: "DELETE", auditLog: auditReason, auth: token.isEmpty));

  @override
  Future<IWebhook> editWebhook(Snowflake webhookId,
      {String token = "", String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (channel != null) "channel_id": channel.id.toString(),
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64(),
    };

    final response = await executeSafe(BasicRequest(
      HttpRoute()..webhooks(id: webhookId.toString(), token: token.toString()),
      method: "PATCH",
      auditLog: auditReason,
      body: body,
      auth: token.isEmpty,
    ));

    return Webhook(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IMessage?> executeWebhook(Snowflake webhookId, MessageBuilder builder,
      {String token = "", bool wait = true, String? avatarUrl, String? username, Snowflake? threadId, String? threadName}) async {
    final queryParams = {"wait": wait, if (threadId != null) "thread_id": threadId};

    final body = {
      ...builder.build(client.options.allowedMentions),
      if (avatarUrl != null) "avatar_url": avatarUrl,
      if (username != null) "username": username,
      if (threadName != null) 'thread_name': threadName,
    };

    HttpResponseSuccess response;
    if (builder.files != null && builder.files!.isNotEmpty) {
      response = await executeSafe(MultipartRequest(
        HttpRoute()..webhooks(id: webhookId.toString(), token: token.toString()),
        builder.getMappedFiles().toList(),
        method: "POST",
        fields: body,
        queryParams: queryParams,
      ));
    } else {
      response = await executeSafe(BasicRequest(
        HttpRoute()..webhooks(id: webhookId.toString(), token: token.toString()),
        body: body,
        method: "POST",
        queryParams: queryParams,
        auth: token.isEmpty,
      ));
    }

    if (wait == true) {
      return WebhookMessage(client, response.jsonBody as RawApiMap, webhookId, token, threadId);
    }

    return null;
  }

  @override
  Future<IWebhook> fetchWebhook(Snowflake id, {String token = ""}) async {
    final response = await executeSafe(BasicRequest(HttpRoute()..webhooks(id: id.toString(), token: token.toString()), auth: token.isEmpty));

    return Webhook(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IInvite> fetchInvite(String code) async {
    final response = await executeSafe(BasicRequest(HttpRoute()..invites(id: code)));

    return Invite(response.jsonBody as RawApiMap, client);
  }

  @override
  String stickerUrl(Snowflake stickerId, String extension) => "https://cdn.${Constants.cdnHost}/stickers/$stickerId.$extension";

  @override
  String emojiUrl(Snowflake emojiId) => "https://cdn.discordapp.com/emojis/$emojiId.png";

  @override
  Future<IDMChannel> createDMChannel(Snowflake userId) async {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..users(id: "@me")
        ..channels(),
      method: "POST",
      body: {
        "recipient_id": userId.toString(),
      },
    ));

    return DMChannel(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<HttpResponse> sendRawRequest(covariant HttpRoute route, String method,
      {dynamic body,
      Map<String, dynamic>? headers,
      List<AttachmentBuilder> files = const [],
      Map<String, dynamic>? queryParams,
      bool auth = false,
      bool rateLimit = true}) async {
    if (files.isNotEmpty) {
      return executeSafe(MultipartRequest(
        route,
        mapMessageBuilderAttachments(files).toList(),
        method: method,
        fields: body,
        queryParams: queryParams,
        globalRateLimit: rateLimit,
        auth: auth,
      ));
    } else {
      return executeSafe(BasicRequest(
        route,
        body: body,
        method: method,
        queryParams: queryParams,
        globalRateLimit: rateLimit,
        auth: auth,
      ));
    }
  }

  Future<HttpResponse> getGatewayBot() => executeSafe(BasicRequest(HttpRoute()
    ..gateway()
    ..bot()));

  Future<HttpResponse> getMeApplication() => executeSafe(BasicRequest(HttpRoute()
    ..oauth2()
    ..applications(id: "@me")));

  @override
  Future<IGuildPreview> fetchGuildPreview(Snowflake guildId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..guilds(id: guildId.toString())
      ..preview()));

    return GuildPreview(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IChannel> createGuildChannel(Snowflake guildId, ChannelBuilder channelBuilder) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..channels(),
        method: "POST",
        body: channelBuilder.build()));

    return Channel.deserialize(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> deleteChannel(Snowflake channelId) async {
    await executeSafe(BasicRequest(HttpRoute()..channels(id: channelId.toString()), method: "DELETE"));
  }

  @override
  Future<IStageChannelInstance> createStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) async {
    final body = {"topic": topic, "channel_id": channelId.toString(), if (privacyLevel != null) "privacy_level": privacyLevel.value};

    final response = await executeSafe(BasicRequest(HttpRoute()..stageInstances(), method: "POST", body: body));

    return StageChannelInstance(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> deleteStageChannelInstance(Snowflake channelId) async {
    await executeSafe(BasicRequest(HttpRoute()..stageInstances(id: channelId.toString()), method: "DELETE"));
  }

  @override
  Future<IStageChannelInstance> getStageChannelInstance(Snowflake channelId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()..stageInstances(id: channelId.toString())));

    return StageChannelInstance(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IStageChannelInstance> updateStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) async {
    final body = {"topic": topic, if (privacyLevel != null) "privacy_level": privacyLevel.value};

    final response = await executeSafe(BasicRequest(HttpRoute()..stageInstances(id: channelId.toString()), method: "POST", body: body));

    return StageChannelInstance(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> addThreadMember(Snowflake channelId, Snowflake userId) async {
    await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..threadMembers(id: userId.toString()),
      method: "PUT",
    ));
  }

  @override
  Future<IThreadListResultWrapper> fetchGuildActiveThreads(Snowflake guildId) async {
    final response = await executeSafe(BasicRequest(HttpRoute()
      ..guilds(id: guildId.toString())
      ..threads()
      ..active()));

    return ThreadListResultWrapper(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..users(id: "@me")
          ..threads()
          ..archived()
          ..private(),
        queryParams: {if (before != null) "before": before.toIso8601String(), if (limit != null) "limit": limit}));

    return ThreadListResultWrapper(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..threads()
          ..archived()
          ..private(),
        queryParams: {if (before != null) "before": before.toIso8601String(), if (limit != null) "limit": limit}));

    return ThreadListResultWrapper(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..threads()
          ..archived()
          ..public(),
        queryParams: {if (before != null) "before": before.toIso8601String(), if (limit != null) "limit": limit}));

    return ThreadListResultWrapper(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> joinThread(Snowflake channelId) async {
    await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..threadMembers(id: "@me"),
      method: "PUT",
    ));
  }

  @override
  Future<void> leaveThread(Snowflake channelId) async {
    await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..threadMembers(id: "@me"),
      method: "DELETE",
    ));
  }

  @override
  Future<void> removeThreadMember(Snowflake channelId, Snowflake userId) async {
    await executeSafe(BasicRequest(
      HttpRoute()
        ..channels(id: channelId.toString())
        ..threadMembers(id: userId.toString()),
      method: "DELETE",
    ));
  }

  @override
  Future<IGuildSticker> createGuildSticker(Snowflake guildId, StickerBuilder builder) async {
    final response = await executeSafe(MultipartRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..stickers(),
        [builder.file.getMultipartFile()],
        fields: builder.build(),
        method: "POST"));

    return GuildSticker(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<IGuildSticker> editGuildSticker(Snowflake guildId, Snowflake stickerId, StickerBuilder builder) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..stickers(id: stickerId.toString()),
        method: "PATCH"));

    return GuildSticker(response.jsonBody as RawApiMap, client);
  }

  @override
  Future<void> deleteGuildSticker(Snowflake guildId, Snowflake stickerId) async {
    await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..stickers(id: stickerId.toString()),
      method: "DELETE",
    ));
  }

  @override
  Future<IGuildSticker> fetchGuildSticker(Snowflake guildId, Snowflake stickerId) async {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..stickers(id: stickerId.toString()),
    ));

    return GuildSticker(response.jsonBody as RawApiMap, client);
  }

  @override
  Stream<IGuildSticker> fetchGuildStickers(Snowflake guildId) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..stickers(),
    ));

    for (final rawSticker in response.jsonBody) {
      yield GuildSticker(rawSticker as RawApiMap, client);
    }
  }

  @override
  Future<IStandardSticker> getSticker(Snowflake id) async {
    final response = await executeSafe(BasicRequest(
      HttpRoute()..stickers(id: id.toString()),
    ));

    return StandardSticker(response.jsonBody as RawApiMap, client);
  }

  @override
  Stream<StickerPack> listNitroStickerPacks() async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()..stickerpacks(),
    ));

    for (final rawSticker in response.jsonBody['sticker_packs']) {
      yield StickerPack(rawSticker as RawApiMap, client);
    }
  }

  @override
  String memberAvatarURL(Snowflake memberId, Snowflake guildId, String avatarHash, {String format = "webp"}) =>
      "${Constants.cdnUrl}/guilds/$guildId/users/$memberId/avatars/$avatarHash.$format";

  @override
  @override
  String? userBannerURL(Snowflake userId, String? hash, {String? format, int? size}) {
    if (hash == null) {
      return null;
    }
    var url = "${Constants.cdnUrl}/banners/$userId/$hash.";

    if (format == null) {
      if (hash.startsWith("a_")) {
        url += "gif";
      } else {
        url += "webp";
      }
    } else {
      url += format;
    }

    if (size != null) {
      url += "?size=$size";
    }

    return url;
  }

  @override
  String getRoleIconUrl(Snowflake roleId, String iconHash, String format, int size) => "${Constants.cdnUrl}/role-icons/$roleId/$iconHash.$format?size=$size";

  @override
  Future<IThreadMember> fetchThreadMember(Snowflake channelId, Snowflake guildId, Snowflake memberId, {bool withMembers = false}) async {
    final result = await executeSafe(BasicRequest(
        HttpRoute()
          ..channels(id: channelId.toString())
          ..threadMembers(id: memberId.toString()),
        queryParams: {'with_member': withMembers}));

    final guildCacheable = GuildCacheable(client, guildId);
    if (withMembers) {
      return ThreadMemberWithMember(client, result.jsonBody as RawApiMap, guildCacheable);
    }

    return ThreadMember(client, result.jsonBody as RawApiMap, guildCacheable);
  }

  @override
  Future<ThreadChannel> editThreadChannel(Snowflake channelId, ThreadBuilder builder, {String? auditReason}) async {
    final response =
        await executeSafe(BasicRequest(HttpRoute()..channels(id: channelId.toString()), method: "PATCH", body: builder.build(), auditLog: auditReason));

    return ThreadChannel(client, response.jsonBody as RawApiMap);
  }

  @override
  Future<GuildEvent> createGuildEvent(Snowflake guildId, GuildEventBuilder builder) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..scheduledEvents(),
        method: 'POST',
        body: builder.build()));

    final event = GuildEvent(response.jsonBody as RawApiMap, client);
    client.guilds[guildId]?.scheduledEvents[event.id] = event;
    return event;
  }

  @override
  Future<void> deleteGuildEvent(Snowflake guildId, Snowflake guildEventId) => executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..scheduledEvents(id: guildEventId.toString()),
      method: 'DELETE'));

  @override
  Future<GuildEvent> editGuildEvent(Snowflake guildId, Snowflake guildEventId, GuildEventBuilder builder) async {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..scheduledEvents(id: guildEventId.toString()),
        method: 'PATCH',
        body: builder.build()));

    final event = GuildEvent(response.jsonBody as RawApiMap, client);
    client.guilds[guildId]?.scheduledEvents[guildEventId] = event;
    return event;
  }

  @override
  Future<GuildEvent> fetchGuildEvent(Snowflake guildId, Snowflake guildEventId) async {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..scheduledEvents(id: guildEventId.toString()),
    ));

    final event = GuildEvent(response.jsonBody as RawApiMap, client);
    client.guilds[guildId]?.scheduledEvents[event.id] = event;
    return event;
  }

  @override
  Stream<GuildEventUser> fetchGuildEventUsers(Snowflake guildId, Snowflake guildEventId,
      {int limit = 100, bool withMember = false, Snowflake? before, Snowflake? after}) async* {
    final response = await executeSafe(BasicRequest(
      HttpRoute()
        ..guilds(id: guildId.toString())
        ..scheduledEvents(id: guildEventId.toString())
        ..users(),
      queryParams: {
        'limit': limit,
        'with_member': withMember,
        if (before != null) 'before': before.toString(),
        if (after != null) 'after': after.toString(),
      },
    ));

    for (final rawGuildEventUser in response.jsonBody as RawApiList) {
      yield GuildEventUser(rawGuildEventUser as RawApiMap, client, guildId);
    }
  }

  @override
  Stream<GuildEvent> fetchGuildEvents(Snowflake guildId, {bool withUserCount = false}) async* {
    final response = await executeSafe(BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..scheduledEvents(),
        method: 'GET',
        queryParams: {'with_user_count': withUserCount.toString()}));

    for (final rawGuildEvent in response.jsonBody as RawApiList) {
      final event = GuildEvent(rawGuildEvent as RawApiMap, client);
      client.guilds[guildId]?.scheduledEvents[event.id] = event;
      yield event;
    }
  }

  @override
  Stream<IAutoModerationRule> fetchAutoModerationRules(Snowflake guildId) async* {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..autoModeration()
          ..rules(),
      ),
    );

    for (final rawRule in response.jsonBody as RawApiList) {
      final rule = AutoModerationRule(rawRule as RawApiMap, client);
      client.guilds[guildId]?.autoModerationRules[rule.id] = rule;
      yield rule;
    }
  }

  @override
  Future<IAutoModerationRule> fetchAutoModerationRule(Snowflake guildId, Snowflake ruleId) async {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..autoModeration()
          ..rules(id: ruleId.toString()),
      ),
    );

    final rule = AutoModerationRule(response.jsonBody as RawApiMap, client);

    client.guilds[guildId]?.autoModerationRules[ruleId] = rule;

    return rule;
  }

  @override
  Future<IAutoModerationRule> createAutoModerationRule(Snowflake guildId, AutoModerationRuleBuilder builder, {String? auditReason}) async {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..autoModeration()
          ..rules(),
        method: 'POST',
        auditLog: auditReason,
        body: builder.build(),
      ),
    );

    final rule = AutoModerationRule(response.jsonBody as RawApiMap, client);

    client.guilds[guildId]?.autoModerationRules[rule.id] = rule;

    return rule;
  }

  @override
  Future<IAutoModerationRule> editAutoModerationRule(Snowflake guildId, Snowflake ruleId, AutoModerationRuleBuilder builder, {String? auditReason}) async {
    final response = await executeSafe(
      BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..autoModeration()
          ..rules(id: ruleId.toString()),
        body: builder.build(),
        auditLog: auditReason,
        method: 'PATCH',
      ),
    );

    final rule = AutoModerationRule(response.jsonBody as RawApiMap, client);

    client.guilds[guildId]?.autoModerationRules[ruleId] = rule;

    return rule;
  }

  @override
  Future<void> deleteAutoModerationRule(Snowflake guildId, Snowflake ruleId, {String? auditReason}) async {
    await executeSafe(
      BasicRequest(
        HttpRoute()
          ..guilds(id: guildId.toString())
          ..autoModeration()
          ..rules(id: ruleId.toString()),
        auditLog: auditReason,
        method: 'DELETE',
      ),
    );

    client.guilds[guildId]?.autoModerationRules.remove(ruleId);
  }
}
