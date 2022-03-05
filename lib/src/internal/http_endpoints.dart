import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';
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
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';
import 'package:nyxx/src/utils/builders/guild_event_builder.dart';
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
  Future<IGuild> fetchGuild(Snowflake guildId);

  /// Fetches [IChannel] from API. Channel cas be cast to wanted type using generics
  Future<T> fetchChannel<T>(Snowflake id);

  /// Returns [BaseGuildEmoji] for given [emojiId]
  Future<IBaseGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId);

  /// Creates emoji in given guild
  Future<IBaseGuildEmoji> createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment});

  /// Fetches a [IUser] that created the emoji from the given [emojiId]
  Future<IUser> fetchEmojiCreator(Snowflake guildId, Snowflake emojiId);

  /// Returns how many user will be pruned in prune operation
  Future<int> guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles});

  /// Executes actual prune action, returning how many users were pruned.
  Future<int> guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason});

  /// Get all guild bans.
  Stream<IBan> getGuildBans(Snowflake guildId);

  Future<void> modifyCurrentMember(Snowflake guildId, {String? nick});

  /// Get [IBan] object for given [bannedUserId]
  Future<IBan> getGuildBan(Snowflake guildId, Snowflake bannedUserId);

  /// Changes guild owner of guild from bot to [member].
  /// Bot needs to be owner of guild to use that endpoint.
  Future<IGuild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason});

  /// Leaves guild with given id
  Future<void> leaveGuild(Snowflake guildId);

  /// Returns list of all guild invites
  Stream<IInvite> fetchGuildInvites(Snowflake guildId);

  /// Creates an activity invite
  Future<IInvite> createVoiceActivityInvite(Snowflake activityId, Snowflake channelId, {int? maxAge, int? maxUses});

  /// Fetches audit logs of guild
  Future<IAuditLog> fetchAuditLogs(Snowflake guildId, {Snowflake? userId, int? actionType, Snowflake? before, int? limit});

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
  Future<IGuild> editGuild(Snowflake guildId,
      {String? name, int? verificationLevel, int? notificationLevel, SnowflakeEntity? afkChannel, int? afkTimeout, String? icon, String? auditReason});

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
  Future<void> editGuildMember(Snowflake guildId, Snowflake memberId,
      {@Deprecated('Use "builder" parameter') String? nick,
      @Deprecated('Use "builder" parameter') List<SnowflakeEntity>? roles,
      @Deprecated('Use "builder" parameter') bool? mute,
      @Deprecated('Use "builder" parameter') bool? deaf,
      @Deprecated('Use "builder" parameter') Snowflake? channel = const Snowflake.zero(),
      MemberBuilder? builder,
      String? auditReason});

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
  Stream<IThreadMember> fetchThreadMembers(Snowflake channelId, Snowflake guildId);

  /// Fetches single thread member
  Future<IThreadMember> fetchThreadMember(Snowflake channelId, Snowflake guildId, Snowflake memberId);

  /// Joins thread with given id
  Future<void> joinThread(Snowflake channelId);

  /// Adds member to thread given bot has sufficient permissions
  Future<void> addThreadMember(Snowflake channelId, Snowflake userId);

  /// Leave thread with given id
  Future<void> leaveThread(Snowflake channelId);

  /// Removes member from thread given bot has sufficient permissions
  Future<void> removeThreadMember(Snowflake channelId, Snowflake userId);

  /// Returns all active threads in given channel
  Future<IThreadListResultWrapper> fetchActiveThreads(Snowflake channelId);

  /// Returns all public archived thread in given channel
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all private archived thread in given channel
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all joined private archived thread in given channel
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Removes all embeds from given message
  Future<IMessage> suppressMessageEmbeds(Snowflake channelId, Snowflake messageId);

  /// Edits message with given id using [builder]
  Future<IMessage> editMessage(Snowflake channelId, Snowflake messageId, MessageBuilder builder);

  /// Edits message sent by webhook
  Future<IMessage> editWebhookMessage(Snowflake webhookId, Snowflake messageId, MessageBuilder builder, {String? token, Snowflake? threadId});

  /// Creates reaction with given [emoji] on given message
  Future<void> createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes all reactions for given [emoji] from message
  Future<void> deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes all reactions of given user from message.
  Future<void> deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId);

  /// Deletes all reactions on given message
  Future<void> deleteMessageAllReactions(Snowflake channelId, Snowflake messageId);

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
      {String token = "", bool wait = true, String? avatarUrl, String? username, Snowflake? threadId});

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
  Future<IHttpResponse> sendRawRequest(String url, String method,
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
  String getUserBannerURL(Snowflake userId, String hash, {String format = "png"});

  Stream<GuildEvent> fetchGuildEvents(Snowflake guildId, {bool withUserCount = false});
  Future<GuildEvent> createGuildEvent(Snowflake guildId, GuildEventBuilder builder);
  Future<GuildEvent> fetchGuildEvent(Snowflake guildId, Snowflake guildEventId);
  Future<GuildEvent> editGuildEvent(Snowflake guildId, Snowflake guildEventId, GuildEventBuilder builder);
  Future<void> deleteGuildEvent(Snowflake guildId, Snowflake guildEventId);
  Stream<GuildEventUser> fetchGuildEventUsers(Snowflake guildId, Snowflake guildEventId,
      {int limit = 100, bool withMember = false, Snowflake? before, Snowflake? after});
}

class HttpEndpoints implements IHttpEndpoints {
  late final HttpHandler httpHandler;
  final INyxx client;

  /// Creates an instance of [HttpEndpoints]
  HttpEndpoints(this.client) {
    httpHandler = client.httpHandler;
  }

  Future<HttpResponse> executeSafe(HttpRequest request) async {
    final response = await httpHandler.execute(request);

    if (response is HttpResponseError) {
      return Future.error(response);
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
  String getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]) => "https://cdn.${Constants.cdnHost}/guilds/$guildId/widget.png?style=$style";

  @override
  Future<GuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId, {String? name, List<Snowflake>? roles, AttachmentBuilder? avatarAttachment}) async {
    if (name == null && roles == null) {
      return Future.error(ArgumentError("Both name and roles fields cannot be null"));
    }

    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString()).toList(),
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64()
    };

    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/emojis/$emojiId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji(client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId) async => executeSafe(BasicRequest("/guilds/$guildId/emojis/$emojiId", method: "DELETE"));

  @override
  Future<Role> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role, {String? auditReason}) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/roles/$roleId", method: "PATCH", body: role.build(), auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Role(client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteRole(Snowflake guildId, Snowflake roleId, {String? auditReason}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/roles/$roleId", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> addRoleToUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/members/$userId/roles/$roleId", method: "PUT", auditLog: auditReason));

  @override
  Future<IGuild> fetchGuild(Snowflake guildId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/${guildId.toString()}"));

    if (response is HttpResponseSuccess) {
      return Guild(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<T> fetchChannel<T>(Snowflake id) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$id"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    final raw = (response as HttpResponseSuccess).jsonBody as RawApiMap;
    return Channel.deserialize(client, raw) as T;
  }

  @override
  Future<IBaseGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/emojis/$emojiId"));

    if (response is HttpResponseSuccess) {
      return GuildEmoji(client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<IBaseGuildEmoji> createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment}) async {
    final body = <String, dynamic>{
      "name": name,
      if (roles != null) "roles": roles.map((r) => r.id.toString()).toList(),
      if (emojiAttachment != null) "image": emojiAttachment.getBase64()
    };

    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/emojis", method: "POST", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji(client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<IUser> fetchEmojiCreator(Snowflake guildId, Snowflake emojiId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/emojis/$emojiId"));

    if (response is HttpResponseSuccess) {
      if (response.jsonBody["managed"] as bool) {
        return Future.error(ArgumentError("Emoji is managed"));
      }

      if (response.jsonBody["user"] == null) {
        return Future.error(ArgumentError("Could not find user creator, make sure you have the correct permissions"));
      }

      return User(client, response.jsonBody["user"] as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<int> guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles}) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/prune",
        queryParams: {"days": days.toString(), if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())}));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  @override
  Future<int> guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/prune",
        method: "POST",
        auditLog: auditReason,
        queryParams: {"days": days.toString()},
        body: {if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())}));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  @override
  Stream<IBan> getGuildBans(Snowflake guildId) async* {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/bans"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final obj in (response as HttpResponseSuccess).jsonBody) {
      yield Ban(obj as RawApiMap, client);
    }
  }

  @override
  Future<void> modifyCurrentMember(Snowflake guildId, {String? nick}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/members/@me/nick", method: "PATCH", body: {if (nick != null) "nick": nick}));

  @override
  Future<IBan> getGuildBan(Snowflake guildId, Snowflake bannedUserId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/bans/$bannedUserId"));

    if (response is HttpResponseSuccess) {
      return Ban(response.jsonBody as RawApiMap, client);
    }

    return Future.error(response);
  }

  @override
  Future<IGuild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason}) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId", method: "PATCH", auditLog: auditReason, body: {"owner_id": member.id}));

    if (response is HttpResponseSuccess) {
      return Guild(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> leaveGuild(Snowflake guildId) async => executeSafe(BasicRequest("/users/@me/guilds/$guildId", method: "DELETE"));

  @override
  Stream<IInvite> fetchGuildInvites(Snowflake guildId) async* {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final raw in (response as HttpResponseSuccess).jsonBody) {
      yield Invite(raw as RawApiMap, client);
    }
  }

  @override
  Future<IInvite> createVoiceActivityInvite(Snowflake activityId, Snowflake channelId, {int? maxAge, int? maxUses}) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/invites", method: "POST", body: {
      "max_age": maxAge ?? 0,
      "max_uses": maxUses ?? 0,
      "target_application_id": "$activityId",
      "target_type": 2,
    }));

    if (response is HttpResponseSuccess) {
      return Invite(response.jsonBody as RawApiMap, client);
    }

    return Future.error(response);
  }

  @override
  Future<IAuditLog> fetchAuditLogs(Snowflake guildId, {Snowflake? userId, int? actionType, Snowflake? before, int? limit}) async {
    final queryParams = <String, String>{
      if (userId != null) "user_id": userId.toString(),
      if (actionType != null) "action_type": actionType.toString(),
      if (before != null) "before": before.toString(),
      if (limit != null) "limit": limit.toString()
    };

    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/audit-logs", queryParams: queryParams));

    if (response is HttpResponseSuccess) {
      return AuditLog(response.jsonBody as RawApiMap, client);
    }

    return Future.error(response);
  }

  @override
  Future<IRole> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder, {String? auditReason}) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/roles", method: "POST", auditLog: auditReason, body: roleBuilder.build()));

    if (response is HttpResponseSuccess) {
      return Role(client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Stream<IVoiceRegion> fetchGuildVoiceRegions(Snowflake guildId) async* {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/regions"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final raw in (response as HttpResponseSuccess).jsonBody) {
      yield VoiceRegion(raw as RawApiMap);
    }
  }

  @override
  Future<void> moveGuildChannel(Snowflake guildId, Snowflake channelId, int position, {String? auditReason}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/channels", method: "PATCH", auditLog: auditReason, body: {"id": channelId.toString(), "position": position}));

  @override
  Future<void> guildBan(Snowflake guildId, Snowflake userId, {int deleteMessageDays = 0, String? auditReason}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/bans/$userId", method: "PUT", auditLog: auditReason, body: {"delete-message-days": deleteMessageDays}));

  @override
  Future<void> guildKick(Snowflake guildId, Snowflake userId, {String? auditReason}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/members/$userId", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> guildUnban(Snowflake guildId, Snowflake userId) async => executeSafe(BasicRequest("/guilds/$guildId/bans/$userId", method: "DELETE"));

  @override
  Future<IGuild> editGuild(Snowflake guildId,
      {String? name, int? verificationLevel, int? notificationLevel, SnowflakeEntity? afkChannel, int? afkTimeout, String? icon, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (verificationLevel != null) "verification_level": verificationLevel,
      if (notificationLevel != null) "default_message_notifications": notificationLevel,
      if (afkChannel != null) "afk_channel_id": afkChannel,
      if (afkTimeout != null) "afk_timeout": afkTimeout,
      if (icon != null) "icon": icon
    };

    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId", method: "PATCH", auditLog: auditReason, body: body));

    if (response is HttpResponseSuccess) {
      return Guild(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IMember> fetchGuildMember(Snowflake guildId, Snowflake memberId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/members/$memberId"));

    if (response is HttpResponseSuccess) {
      final member = Member(client, response.jsonBody as RawApiMap, guildId);

      if (client.cacheOptions.memberCachePolicyLocation.http && client.cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      return member;
    }

    return Future.error(response);
  }

  @override
  Stream<IMember> fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after}) async* {
    final request = await httpHandler
        .execute(BasicRequest("/guilds/$guildId/members", queryParams: {"limit": limit.toString(), if (after != null) "after": after.toString()}));

    if (request is HttpResponseError) {
      yield* Stream.error(request);
      return;
    }

    for (final rawMember in (request as HttpResponseSuccess).jsonBody as RawApiList) {
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
      yield* Stream.error(ArgumentError("`query` parameter cannot be empty. If you want to request all members use `fetchGuildMembers`"));
      return;
    }

    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/members/search", queryParams: {"query": query, "limit": limit.toString()}));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final RawApiMap memberData in (response as HttpResponseSuccess).jsonBody) {
      final member = Member(client, memberData, guildId);

      if (client.cacheOptions.memberCachePolicyLocation.http && client.cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      yield member;
    }
  }

  @override
  Stream<IWebhook> fetchChannelWebhooks(Snowflake channelId) async* {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/webhooks"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final raw in (response as HttpResponseSuccess).jsonBody) {
      yield Webhook(raw as RawApiMap, client);
    }
  }

  @override
  Future<void> deleteGuild(Snowflake guildId) async => executeSafe(BasicRequest("/guilds/$guildId", method: "DELETE"));

  @override
  Stream<IRole> fetchGuildRoles(Snowflake guildId) async* {
    final response = await httpHandler.execute(BasicRequest("/guilds/${guildId.toString()}/roles"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final rawRole in (response as HttpResponseSuccess).jsonBody) {
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
    final response = await httpHandler.execute(BasicRequest("/users/$userId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return User(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> editGuildMember(Snowflake guildId, Snowflake memberId,
      {String? nick = "",
      List<SnowflakeEntity>? roles,
      bool? mute,
      bool? deaf,
      Snowflake? channel = const Snowflake.zero(),
      MemberBuilder? builder,
      String? auditReason}) {
    final finalBuilder = builder ?? MemberBuilder()
      ..nick = nick
      ..roles = roles?.map((e) => e.id).toList()
      ..mute = mute
      ..deaf = deaf
      ..channel = channel;

    return executeSafe(BasicRequest("/guilds/$guildId/members/$memberId", method: "PATCH", auditLog: auditReason, body: finalBuilder.build()));
  }

  @override
  Future<void> removeRoleFromUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async =>
      executeSafe(BasicRequest("/guilds/$guildId/members/$userId/roles/$roleId", method: "DELETE", auditLog: auditReason));

  @override
  Stream<IInviteWithMeta> fetchChannelInvites(Snowflake channelId) async* {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    final bodyValues = (response as HttpResponseSuccess).jsonBody.values.first;

    for (final val in bodyValues as Iterable<RawApiMap>) {
      yield InviteWithMeta(val, client);
    }
  }

  @override
  Future<void> editChannelPermissions(Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) async {
    await executeSafe(BasicRequest("/channels/$channelId/permissions/${entity.id.toString()}",
        method: "PUT", body: {"type": entity is IRole ? 0 : 1, ...perms.build()}, auditLog: auditReason));
  }

  @override
  Future<void> editChannelPermissionOverrides(Snowflake channelId, PermissionOverrideBuilder permissionBuilder, {String? auditReason}) async {
    await executeSafe(BasicRequest("/channels/$channelId/permissions/${permissionBuilder.id.toString()}",
        method: "PUT", body: permissionBuilder.build(), auditLog: auditReason));
  }

  @override
  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id, {String? auditReason}) async =>
      executeSafe(BasicRequest("/channels/$channelId/permissions/$id", method: "PUT", auditLog: auditReason));

  @override
  Future<IInviteWithMeta> createInvite(Snowflake channelId, {int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) async {
    final body = {
      if (maxAge != null) "max_age": maxAge,
      if (maxUses != null) "max_uses": maxUses,
      if (temporary != null) "temporary": temporary,
      if (unique != null) "unique": unique,
    };

    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/invites", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return InviteWithMeta((response as HttpResponseSuccess).jsonBody as RawApiMap, client);
  }

  @override
  Future<IMessage> sendMessage(Snowflake channelId, MessageBuilder builder) async {
    if (!builder.canBeUsedAsNewMessage()) {
      return Future.error(ArgumentError("Cannot sent message when MessageBuilder doesn't have set either content, embed or files"));
    }

    HttpResponse response;
    if (builder.hasFiles()) {
      response = await httpHandler.execute(MultipartRequest("/channels/$channelId/messages", builder.getMappedFiles().toList(),
          method: "POST", fields: builder.build(client.options.allowedMentions)));
    } else {
      response = await httpHandler.execute(BasicRequest("/channels/$channelId/messages", body: builder.build(client.options.allowedMentions), method: "POST"));
    }

    if (response is HttpResponseSuccess) {
      return Message(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IMessage> fetchMessage(Snowflake channelId, Snowflake messageId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/messages/$messageId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return Message(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> bulkRemoveMessages(Snowflake channelId, Iterable<SnowflakeEntity> messagesIds) async {
    await for (final chunk in messagesIds.toList().chunk(90)) {
      final response = await httpHandler
          .execute(BasicRequest("/channels/$channelId/messages/bulk-delete", method: "POST", body: {"messages": chunk.map((f) => f.id.toString()).toList()}));

      if (response is HttpResponseError) {
        return Future.error(response);
      }
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

    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/messages", queryParams: queryParams));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final val in await (response as HttpResponseSuccess).jsonBody) {
      yield Message(client, val as RawApiMap);
    }
  }

  @override
  Future<T> editGuildChannel<T extends IGuildChannel>(Snowflake channelId, ChannelBuilder builder, {String? auditReason}) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId", method: "PATCH", body: builder.build(), auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Channel.deserialize(client, response.jsonBody as RawApiMap) as T;
    }

    return Future.error(response);
  }

  @override
  Future<IWebhook> createWebhook(Snowflake channelId, String name, {AttachmentBuilder? avatarAttachment, String? auditReason}) async {
    if (name.isEmpty || name.length > 80) {
      return Future.error(ArgumentError("Webhook name cannot be shorter than 1 character and longer than 80 characters"));
    }

    final body = <String, dynamic>{
      "name": name,
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64(),
    };

    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/webhooks", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Webhook(response.jsonBody as RawApiMap, client);
    }

    return Future.error(response);
  }

  @override
  Stream<IMessage> fetchPinnedMessages(Snowflake channelId) async* {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/pins"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final val in (response as HttpResponseSuccess).jsonBody as RawApiList) {
      yield Message(client, val as RawApiMap);
    }
  }

  @override
  Future<void> triggerTyping(Snowflake channelId) => executeSafe(BasicRequest("/channels/$channelId/typing", method: "POST"));

  @override
  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId) async =>
      executeSafe(BasicRequest("/channels/$channelId/messages/$messageId/crosspost", method: "POST"));

  @override
  Future<IThreadPreviewChannel> createThreadWithMessage(Snowflake channelId, Snowflake messageId, ThreadBuilder builder) async {
    final response = await httpHandler.execute(
      BasicRequest(
        "/channels/$channelId/messages/$messageId/threads",
        method: "POST",
        body: builder.build(),
      ),
    );

    if (response is HttpResponseSuccess) {
      return ThreadPreviewChannel(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IThreadPreviewChannel> createThread(Snowflake channelId, ThreadBuilder builder) async {
    final response = await httpHandler.execute(
      BasicRequest(
        "/channels/$channelId/threads",
        method: "POST",
        body: builder.build(),
      ),
    );

    if (response is HttpResponseSuccess) {
      return ThreadPreviewChannel(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Stream<IThreadMember> fetchThreadMembers(Snowflake channelId, Snowflake guildId) async* {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/thread-members"));

    if (response is HttpResponseSuccess) {
      final guild = GuildCacheable(client, guildId);

      for (final rawThreadMember in response.jsonBody as RawApiList) {
        yield ThreadMember(client, rawThreadMember as RawApiMap, guild);
      }
    }

    yield* Stream.error(response);
  }

  @override
  Future<IMessage> suppressMessageEmbeds(Snowflake channelId, Snowflake messageId) async {
    final body = <String, dynamic>{"flags": 1 << 2};

    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/messages/$messageId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return Message(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IMessage> editMessage(Snowflake channelId, Snowflake messageId, MessageBuilder builder) async {
    HttpResponse response;
    if (builder.hasFiles()) {
      response = await httpHandler.execute(MultipartRequest("/channels/$channelId/messages/$messageId", builder.getMappedFiles().toList(),
          method: "PATCH", fields: builder.build(client.options.allowedMentions)));
    } else {
      response = await httpHandler
          .execute(BasicRequest("/channels/$channelId/messages/$messageId", body: builder.build(client.options.allowedMentions), method: "PATCH"));
    }

    if (response is HttpResponseSuccess) {
      return Message(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IMessage> editWebhookMessage(Snowflake webhookId, Snowflake messageId, MessageBuilder builder, {String? token, Snowflake? threadId}) async {
    HttpResponse response;
    if (builder.hasFiles()) {
      response = await httpHandler.execute(MultipartRequest(
          "/webhooks/$webhookId/${token != null ? '$token/' : ''}messages/$messageId", builder.getMappedFiles().toList(),
          method: "PATCH", fields: builder.build(client.options.allowedMentions), queryParams: {if (threadId != null) 'thread_id': threadId}));
    } else {
      response = await httpHandler.execute(BasicRequest("/webhooks/$webhookId/${token != null ? '$token/' : ''}messages/$messageId",
          body: builder.build(client.options.allowedMentions), method: "PATCH", queryParams: {if (threadId != null) 'thread_id': threadId}));
    }

    if (response is HttpResponseSuccess) {
      return Message(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      executeSafe(BasicRequest("/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me", method: "PUT"));

  @override
  Future<void> deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      executeSafe(BasicRequest("/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me", method: "DELETE"));

  @override
  Future<void> deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId) =>
      executeSafe(BasicRequest("/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/$userId", method: "DELETE"));

  @override
  Future<void> deleteMessageAllReactions(Snowflake channelId, Snowflake messageId) =>
      executeSafe(BasicRequest("/channels/$channelId/messages/$messageId/reactions", method: "DELETE"));

  @override
  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId, {String? auditReason}) =>
      executeSafe(BasicRequest("/channels/$channelId/messages/$messageId", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> deleteWebhookMessage(Snowflake webhookId, Snowflake messageId, {String? auditReason, String? token, Snowflake? threadId}) =>
      executeSafe(BasicRequest("/webhooks/$webhookId/${token != null ? '$token/' : ''}messages/$messageId",
          method: "DELETE", auditLog: auditReason, queryParams: {if (threadId != null) 'thread_id': threadId}));

  @override
  Future<void> pinMessage(Snowflake channelId, Snowflake messageId) => executeSafe(BasicRequest("/channels/$channelId/pins/$messageId", method: "PUT"));

  @override
  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId) => executeSafe(BasicRequest("/channels/$channelId/pins/$messageId", method: "DELETE"));

  @override
  Future<IUser> editSelfUser({String? username, AttachmentBuilder? avatarAttachment}) async {
    final body = <String, dynamic>{
      if (username != null) "username": username,
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64(),
    };

    final response = await httpHandler.execute(BasicRequest("/users/@me", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return User(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteInvite(String code, {String? auditReason}) async => executeSafe(BasicRequest("/invites/$code", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> deleteWebhook(Snowflake id, {String token = "", String? auditReason}) =>
      executeSafe(BasicRequest("/webhooks/$id/$token", method: "DELETE", auditLog: auditReason, auth: token.isEmpty));

  @override
  Future<IWebhook> editWebhook(Snowflake webhookId,
      {String token = "", String? name, SnowflakeEntity? channel, AttachmentBuilder? avatarAttachment, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (channel != null) "channel_id": channel.id.toString(),
      if (avatarAttachment != null) "avatar": avatarAttachment.getBase64(),
    };

    final response =
        await httpHandler.execute(BasicRequest("/webhooks/$webhookId/$token", method: "PATCH", auditLog: auditReason, body: body, auth: token.isEmpty));

    return Future.error(response);
  }

  @override
  Future<IMessage?> executeWebhook(Snowflake webhookId, MessageBuilder builder,
      {String token = "", bool wait = true, String? avatarUrl, String? username, Snowflake? threadId}) async {
    final queryParams = {"wait": wait, if (threadId != null) "thread_id": threadId};

    final body = {
      ...builder.build(client.options.allowedMentions),
      if (avatarUrl != null) "avatar_url": avatarUrl,
      if (username != null) "username": username,
    };

    HttpResponse response;
    if (builder.files != null && builder.files!.isNotEmpty) {
      response = await httpHandler
          .execute(MultipartRequest("/webhooks/$webhookId/$token", builder.getMappedFiles().toList(), method: "POST", fields: body, queryParams: queryParams));
    } else {
      response =
          await httpHandler.execute(BasicRequest("/webhooks/$webhookId/$token", body: body, method: "POST", queryParams: queryParams, auth: token.isEmpty));
    }

    if (response is HttpResponseSuccess) {
      if (wait == true) {
        return WebhookMessage(client, response.jsonBody as RawApiMap, webhookId, token, threadId);
      }

      return null;
    }

    return Future.error(response);
  }

  @override
  Future<IWebhook> fetchWebhook(Snowflake id, {String token = ""}) async {
    final response = await httpHandler.execute(BasicRequest("/webhooks/$id/$token", auth: token.isEmpty));

    if (response is HttpResponseSuccess) {
      return Webhook(response.jsonBody as RawApiMap, client);
    }

    return Future.error(response);
  }

  @override
  Future<IInvite> fetchInvite(String code) async {
    final response = await httpHandler.execute(BasicRequest("/invites/$code"));

    if (response is HttpResponseSuccess) {
      return Invite(response.jsonBody as RawApiMap, client);
    }

    return Future.error(response);
  }

  @override
  String stickerUrl(Snowflake stickerId, String extension) => "https://cdn.${Constants.cdnHost}/stickers/$stickerId.$extension";

  @override
  String emojiUrl(Snowflake emojiId) => "https://cdn.discordapp.com/emojis/$emojiId.png";

  @override
  Future<IDMChannel> createDMChannel(Snowflake userId) async {
    final response = await httpHandler.execute(BasicRequest("/users/@me/channels", method: "POST", body: {"recipient_id": userId.toString()}));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return DMChannel(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<HttpResponse> sendRawRequest(String url, String method,
      {dynamic body,
      Map<String, dynamic>? headers,
      List<AttachmentBuilder> files = const [],
      Map<String, dynamic>? queryParams,
      bool auth = false,
      bool rateLimit = true}) async {
    HttpResponse response;
    if (files.isNotEmpty) {
      response = await httpHandler.execute(MultipartRequest(url, mapMessageBuilderAttachments(files).toList(),
          method: method, fields: body, queryParams: queryParams, rateLimit: rateLimit, auth: auth));
    } else {
      response = await httpHandler.execute(BasicRequest(url, body: body, method: method, queryParams: queryParams, rateLimit: rateLimit, auth: auth));
    }

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return response;
  }

  Future<HttpResponse> getGatewayBot() => executeSafe(BasicRequest("/gateway/bot"));

  Future<HttpResponse> getMeApplication() => executeSafe(BasicRequest("/oauth2/applications/@me"));

  @override
  Future<IGuildPreview> fetchGuildPreview(Snowflake guildId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/preview"));

    if (response is HttpResponseSuccess) {
      return GuildPreview(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IChannel> createGuildChannel(Snowflake guildId, ChannelBuilder channelBuilder) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/${guildId.toString()}/channels", method: "POST", body: channelBuilder.build()));

    if (response is HttpResponseSuccess) {
      return Channel.deserialize(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteChannel(Snowflake channelId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/${channelId.toString()}", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IStageChannelInstance> createStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) async {
    final body = {"topic": topic, "channel_id": channelId.toString(), if (privacyLevel != null) "privacy_level": privacyLevel.value};

    final response = await httpHandler.execute(BasicRequest("/stage-instances", method: "POST", body: body));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StageChannelInstance(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> deleteStageChannelInstance(Snowflake channelId) async {
    final response = await httpHandler.execute(BasicRequest("/stage-instances/${channelId.toString()}", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IStageChannelInstance> getStageChannelInstance(Snowflake channelId) async {
    final response = await httpHandler.execute(BasicRequest("/stage-instances/${channelId.toString()}"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StageChannelInstance(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<IStageChannelInstance> updateStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) async {
    final body = {"topic": topic, if (privacyLevel != null) "privacy_level": privacyLevel.value};

    final response = await httpHandler.execute(BasicRequest("/stage-instances/${channelId.toString()}", method: "POST", body: body));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StageChannelInstance(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> addThreadMember(Snowflake channelId, Snowflake userId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/thread-members/$userId", method: "PUT"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IThreadListResultWrapper> fetchActiveThreads(Snowflake channelId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/threads/active"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/users/@me/threads/archived/private",
        queryParams: {if (before != null) "before": before.toIso8601String(), if (limit != null) "limit": limit}));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/threads/archived/private",
        queryParams: {if (before != null) "before": before.toIso8601String(), if (limit != null) "limit": limit}));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/threads/archived/public",
        queryParams: {if (before != null) "before": before.toIso8601String(), if (limit != null) "limit": limit}));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper(client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> joinThread(Snowflake channelId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/thread-members/@me", method: "PUT"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<void> leaveThread(Snowflake channelId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/thread-members/@me", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<void> removeThreadMember(Snowflake channelId, Snowflake userId) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId/thread-members/$userId", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IGuildSticker> createGuildSticker(Snowflake guildId, StickerBuilder builder) async {
    final response =
        await httpHandler.execute(MultipartRequest("/guilds/$guildId/stickers", [builder.file.getMultipartFile()], fields: builder.build(), method: "POST"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return GuildSticker((response as HttpResponseSuccess).jsonBody as RawApiMap, client);
  }

  @override
  Future<IGuildSticker> editGuildSticker(Snowflake guildId, Snowflake stickerId, StickerBuilder builder) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/stickers/$stickerId", method: "PATCH"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return GuildSticker((response as HttpResponseSuccess).jsonBody as RawApiMap, client);
  }

  @override
  Future<void> deleteGuildSticker(Snowflake guildId, Snowflake stickerId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/stickers/$stickerId", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IGuildSticker> fetchGuildSticker(Snowflake guildId, Snowflake stickerId) async {
    final response = await httpHandler.execute(BasicRequest(
      "/guilds/$guildId/stickers/$stickerId",
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return GuildSticker((response as HttpResponseSuccess).jsonBody as RawApiMap, client);
  }

  @override
  Stream<IGuildSticker> fetchGuildStickers(Snowflake guildId) async* {
    final response = await httpHandler.execute(BasicRequest(
      "/guilds/$guildId/stickers",
    ));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawSticker in (response as HttpResponseSuccess).jsonBody) {
      yield GuildSticker(rawSticker as RawApiMap, client);
    }
  }

  @override
  Future<IStandardSticker> getSticker(Snowflake id) async {
    final response = await httpHandler.execute(BasicRequest(
      "/stickers/$id",
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StandardSticker((response as HttpResponseSuccess).jsonBody as RawApiMap, client);
  }

  @override
  Stream<StickerPack> listNitroStickerPacks() async* {
    final response = await httpHandler.execute(BasicRequest(
      "/sticker-packs",
    ));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawSticker in (response as HttpResponseSuccess).jsonBody) {
      yield StickerPack(rawSticker as RawApiMap, client);
    }
  }

  @override
  String memberAvatarURL(Snowflake memberId, Snowflake guildId, String avatarHash, {String format = "webp"}) =>
      "${Constants.cdnUrl}/guilds/$guildId/users/$memberId/avatars/$avatarHash.$format";

  @override
  String getUserBannerURL(Snowflake userId, String hash, {String format = "png"}) => "${Constants.cdnUrl}/banners/$userId/$hash.$format";

  @override
  String getRoleIconUrl(Snowflake roleId, String iconHash, String format, int size) => "${Constants.cdnUrl}/role-icons/$roleId/$iconHash.$format?size=$size";

  @override
  Future<IThreadMember> fetchThreadMember(Snowflake channelId, Snowflake guildId, Snowflake memberId) async {
    final result = await httpHandler.execute(BasicRequest('/channels/$channelId/thread-members/$memberId'));

    if (result is IHttpResponseError) {
      return Future.error(result);
    }

    return ThreadMember(client, (result as IHttpResponseSucess).jsonBody as RawApiMap, GuildCacheable(client, guildId));
  }

  @override
  Future<ThreadChannel> editThreadChannel(Snowflake channelId, ThreadBuilder builder, {String? auditReason}) async {
    final response = await httpHandler.execute(BasicRequest("/channels/$channelId", method: "PATCH", body: builder.build(), auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return ThreadChannel(client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<GuildEvent> createGuildEvent(Snowflake guildId, GuildEventBuilder builder) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/${guildId.toString()}/scheduled-events", method: 'POST', body: builder.build()));

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return GuildEvent((response as IHttpResponseSucess).jsonBody as RawApiMap, client);
  }

  @override
  Future<void> deleteGuildEvent(Snowflake guildId, Snowflake guildEventId) =>
      executeSafe(BasicRequest("/guilds/$guildId/scheduled-events/$guildEventId", method: 'DELETE'));

  @override
  Future<GuildEvent> editGuildEvent(Snowflake guildId, Snowflake guildEventId, GuildEventBuilder builder) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/scheduled-events/$guildEventId", method: 'PATCH', body: builder.build()));

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return GuildEvent((response as IHttpResponseSucess).jsonBody as RawApiMap, client);
  }

  @override
  Future<GuildEvent> fetchGuildEvent(Snowflake guildId, Snowflake guildEventId) async {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/scheduled-events/$guildEventId", method: 'GET'));

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return GuildEvent((response as IHttpResponseSucess).jsonBody as RawApiMap, client);
  }

  @override
  Stream<GuildEventUser> fetchGuildEventUsers(Snowflake guildId, Snowflake guildEventId,
      {int limit = 100, bool withMember = false, Snowflake? before, Snowflake? after}) async* {
    final response = await httpHandler.execute(BasicRequest("/guilds/$guildId/scheduled-events/$guildEventId/users", method: 'GET', queryParams: {
      'limit': limit,
      'with_member': withMember,
      if (before != null) 'before': before.toString(),
      if (after != null) 'after': after.toString(),
    }));

    if (response is IHttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawGuildEventUser in (response as IHttpResponseSucess).jsonBody as RawApiList) {
      yield GuildEventUser(rawGuildEventUser as RawApiMap, client, guildId);
    }
  }

  @override
  Stream<GuildEvent> fetchGuildEvents(Snowflake guildId, {bool withUserCount = false}) async* {
    final response =
        await httpHandler.execute(BasicRequest("/guilds/$guildId/scheduled-events", method: 'GET', queryParams: {'with_user_count': withUserCount.toString()}));

    if (response is IHttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawGuildEvent in (response as IHttpResponseSucess).jsonBody as RawApiList) {
      yield GuildEvent(rawGuildEvent as RawApiMap, client);
    }
  }
}
