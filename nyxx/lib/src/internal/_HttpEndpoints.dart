part of nyxx;

abstract class IHttpEndpoints {
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
  Future<GuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId,
      {String? name, List<Snowflake>? roles, File? avatar, String? encodedAvatar, List<int>? avatarBytes, String? encodedExtension});

  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId);

  Future<Role> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role, {String? auditReason});

  Future<void> deleteRole(Snowflake guildId, Snowflake roleId, {String? auditReason});

  Future<void> addRoleToUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason});

  Future<Guild> fetchGuild(Snowflake guildId);

  Future<T> fetchChannel<T>(Snowflake id);

  Future<IGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId);

  Future<GuildEmoji> createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, File? imageFile, List<int>? imageBytes, String? encodedImage, String? encodedExtension});

    Future<int> guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles});

  Future<int> guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason});

  Stream<Ban> getGuildBans(Snowflake guildId);

  Future<void> changeGuildSelfNick(Snowflake guildId, String nick);

  Future<Ban> getGuildBan(Snowflake guildId, Snowflake bannedUserId);

  Future<Guild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason});

  Future<void> leaveGuild(Snowflake guildId);

  Stream<Invite> fetchGuildInvites(Snowflake guildId);

  Future<AuditLog> fetchAuditLogs(Snowflake guildId, {Snowflake? userId, int? actionType, Snowflake? before, int? limit});

  Future<Role> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder, {String? auditReason});

  Stream<VoiceRegion> fetchGuildVoiceRegions(Snowflake guildId);

  Future<void> moveGuildChannel(Snowflake guildId, Snowflake channelId, int position, {String? auditReason});

  Future<void> guildBan(Snowflake guildId, Snowflake userId, {int deleteMessageDays = 0, String? auditReason});

  Future<void> guildKick(Snowflake guildId, Snowflake userId, {String? auditReason});

  Future<void> guildUnban(Snowflake guildId, Snowflake userId);

  Future<Guild> editGuild(
      Snowflake guildId,
      {String? name,
        int? verificationLevel,
        int? notificationLevel,
        SnowflakeEntity? afkChannel,
        int? afkTimeout,
        String? icon,
        String? auditReason});

  Future<Member> fetchGuildMember(Snowflake guildId, Snowflake memberId);

  Stream<Member> fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after});

  Stream<Member> searchGuildMembers(Snowflake guildId, String query, {int limit = 1});

  Stream<Webhook> fetchChannelWebhooks(Snowflake channelId);

  Future<void> deleteGuild(Snowflake guildId);

  Stream<Role> fetchGuildRoles(Snowflake guildId);

  String userAvatarURL(Snowflake userId, String? avatarHash, int discriminator, {String format = "webp", int size = 128});

  Future<User> fetchUser(Snowflake userId);

  Future<void> editGuildMember(
      Snowflake guildId,
      Snowflake memberId,
      {String? nick,
        List<SnowflakeEntity>? roles,
        bool? mute,
        bool? deaf,
        SnowflakeEntity? channel,
        String? auditReason});

  Future<void> removeRoleFromUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason});

  Stream<InviteWithMeta> fetchChannelInvites(Snowflake channelId);

  Future<void> editChannelPermissions(Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason});

  Future<void> editChannelPermissionOverrides(Snowflake channelId, PermissionOverrideBuilder permissionBuilder, {String? auditReason});

  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id, {String? auditReason});

  Future<Invite> createInvite(Snowflake channelId, {int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason});

  Future<Message> sendMessage(
      Snowflake channelId,
      {dynamic content,
        List<AttachmentBuilder>? files,
        EmbedBuilder? embed,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder,
        ReplyBuilder? replyBuilder
      });

  Future<Message> fetchMessage(Snowflake channelId, Snowflake messageId);

  Future<void> bulkRemoveMessages(Snowflake channelId, Iterable<SnowflakeEntity> messagesIds);

  Stream<Message> downloadMessages(Snowflake channelId, {int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around});

  Future<VoiceGuildChannel> editVoiceChannel(Snowflake channelId, {String? name, int? bitrate, int? position, int? userLimit, String? auditReason});

  Future<Webhook> createWebhook(Snowflake channelId, String name, {File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension, String? auditReason});

  Stream<Message> fetchPinnedMessages(Snowflake channelId);

  Future<TextGuildChannel> editTextChannel(Snowflake channelId, {String? name, String? topic, int? position, int? slowModeThreshold});

  Future<void> triggerTyping(Snowflake channelId);

  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId);

  Future<Message> suppressMessageEmbeds(Snowflake channelId, Snowflake messageId);

  Future<Message> editMessage(Snowflake channelId, Snowflake messageId, {dynamic content, EmbedBuilder? embed, AllowedMentions? allowedMentions, MessageEditBuilder? builder});

  Future<void> createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  Future<void> deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji);

  Future<void> deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId);

  Future<void> deleteMessageAllReactions(Snowflake channelId, Snowflake messageId);

  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId, {String? auditReason});

  Future<void> pinMessage(Snowflake channelId, Snowflake messageId);

  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId);

  Future<User> editSelfUser({String? username, File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension});

  Future<void> deleteInvite(String code, {String? auditReason});

  Future<void> deleteWebhook(Snowflake id, {String token = "", String? auditReason});

  Future<Webhook> editWebhook(Snowflake webhookId, {String token ="", String? name, SnowflakeEntity? channel, File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension, String? auditReason});

  Future<Message> executeWebhook(
      Snowflake webhookId,
      { String token = "",
        dynamic content,
        List<AttachmentBuilder>? files,
        List<EmbedBuilder>? embeds,
        bool? tts,
        AllowedMentions? allowedMentions,
        bool? wait,
        String? avatarUrl});

  Future<Webhook> fetchWebhook(Snowflake id, {String token = ""});

  Future<Invite> fetchInvite(String code);
}

class _HttpEndpoints implements IHttpEndpoints {
  late final _HttpHandler _httpClient;
  final Nyxx _client;

  _HttpEndpoints._new(this._client) {
    this._httpClient = this._client._http;
  }

  Map<String, dynamic> _initMessage(dynamic content, EmbedBuilder? embed, AllowedMentions? allowedMentions, ReplyBuilder? replyBuilder) {
    if (content == null && embed == null) {
      throw ArgumentError("When sending message both content and embed cannot be null");
    }

    allowedMentions ??= _client._options.allowedMentions;

    return <String, dynamic>{
      if (content != null) "content": content.toString(),
      if (embed != null) "embed": embed._build(),
      if (allowedMentions != null) "allowed_mentions": allowedMentions._build(),
      if (replyBuilder != null) "message_reference": replyBuilder._build(),
    };
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
  String getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]) =>
      "http://cdn.${Constants.cdnHost}/guilds/$guildId/widget.png?style=$style";
  
  @override
  Future<GuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId,
      {String? name, List<Snowflake>? roles, File? avatar, String? encodedAvatar, List<int>? avatarBytes, String? encodedExtension}) async {
    if (name == null && roles == null) {
      return Future.error(ArgumentError("Both name and roles fields cannot be null"));
    }

    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString())
    };

    final uploadString = Utils.getBase64UploadString(file: avatar, fileBytes: avatarBytes, base64EncodedFile: encodedAvatar, fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/$guildId/emojis/$emojiId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }
  
  @override
  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId) async =>
      _httpClient._execute(
          BasicRequest._new("/guilds/$guildId/emojis/$emojiId", method: "DELETE"));
  
  @override
  Future<Role> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role, {String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles/$roleId",
        method: "PATCH", body: role._build(), auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Role._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteRole(Snowflake guildId, Snowflake roleId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles/$roleId", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> addRoleToUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$userId/roles/$roleId", method: "PUT", auditLog: auditReason));

  @override
  Future<Guild> fetchGuild(Snowflake guildId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId"));

    if (response is HttpResponseSuccess) {
      return Guild._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  @override
  Future<T> fetchChannel<T>(Snowflake id) async {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$id"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    final raw = (response as HttpResponseSuccess)._jsonBody as Map<String, dynamic>;
    return IChannel._deserialize(_client, raw) as T;
  }

  @override
  Future<IGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/emojis/$emojiId"));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<GuildEmoji> createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, File? imageFile, List<int>? imageBytes, String? encodedImage, String? encodedExtension}) async {
    final body = <String, dynamic>{
      "name": name,
      if (roles != null) "roles": roles.map((r) => r.id.toString())
    };

    final uploadString = Utils.getBase64UploadString(file: imageFile, fileBytes: imageBytes, base64EncodedFile: encodedImage, fileExtension: encodedExtension);
    if (uploadString != null) {
      body["image"] = uploadString;
    }

    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/emojis", method: "POST", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<int> guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles}) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/prune", queryParams: {
      "days": days.toString(),
      if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())
    }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  @override
  Future<int> guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/prune",
        method: "POST",
        auditLog: auditReason,
        queryParams: { "days": days.toString() },
        body: {
          if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())
        }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }
  
  @override
  Stream<Ban> getGuildBans(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final obj in (response as HttpResponseSuccess)._jsonBody) {
      yield Ban._new(obj as Map<String, dynamic>, _client);
    }
  }
  
  @override
  Future<void> changeGuildSelfNick(Snowflake guildId, String nick) async =>
      _httpClient._execute(
          BasicRequest._new("/guilds/$guildId/members/@me/nick", method: "PATCH", body: {"nick": nick}));
  
  @override
  Future<Ban> getGuildBan(Snowflake guildId, Snowflake bannedUserId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$bannedUserId"));

    if (response is HttpResponseSuccess) {
      return Ban._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }
  
  @override
  Future<Guild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason}) async {
    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/$guildId", method: "PATCH", auditLog: auditReason, body: {"owner_id": member.id}));

    if (response is HttpResponseSuccess) {
      return Guild._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }
  
  @override
  Future<void> leaveGuild(Snowflake guildId) async =>
      _httpClient._execute(BasicRequest._new("/users/@me/guilds/$guildId", method: "DELETE"));
  
  @override
  Stream<Invite> fetchGuildInvites(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield Invite._new(raw as Map<String, dynamic>, _client);
    }
  }

  @override
  Future<AuditLog> fetchAuditLogs(Snowflake guildId, {Snowflake? userId, int? actionType, Snowflake? before, int? limit}) async {
    final queryParams = <String, String>{
      if (userId != null) "user_id": userId.toString(),
      if (actionType != null) "action_type": actionType.toString(),
      if (before != null) "before": before.toString(),
      if (limit != null) "limit": limit.toString()
    };

    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/audit-logs", queryParams: queryParams));

    if (response is HttpResponseSuccess) {
      return AuditLog._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }

  @override
  Future<Role> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder, {String? auditReason}) async {
    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/$guildId/roles", method: "POST", auditLog: auditReason, body: roleBuilder._build()));

    if (response is HttpResponseSuccess) {
      return Role._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  @override
  Stream<VoiceRegion> fetchGuildVoiceRegions(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/regions"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield VoiceRegion._new(raw as Map<String, dynamic>);
    }
  }

  @override
  Future<void> moveGuildChannel(Snowflake guildId, Snowflake channelId, int position, {String? auditReason}) async {
    await _httpClient._execute(BasicRequest._new("/guilds/$guildId/channels",
        method: "PATCH", auditLog: auditReason, body: {"id": channelId.toString(), "position": position}));
  }

  @override
  Future<void> guildBan(Snowflake guildId, Snowflake userId, {int deleteMessageDays = 0, String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$userId",
          method: "PUT", auditLog: auditReason, body: {"delete-message-days": deleteMessageDays}));

  @override
  Future<void> guildKick(Snowflake guildId, Snowflake userId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$userId",
          method: "DELTE", auditLog: auditReason));

  @override
  Future<void> guildUnban(Snowflake guildId, Snowflake userId) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$userId", method: "DELETE"));

  @override
  Future<Guild> editGuild(
      Snowflake guildId,
      {String? name,
        int? verificationLevel,
        int? notificationLevel,
        SnowflakeEntity? afkChannel,
        int? afkTimeout,
        String? icon,
        String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (verificationLevel != null) "verification_level": verificationLevel,
      if (notificationLevel != null) "default_message_notifications": notificationLevel,
      if (afkChannel != null) "afk_channel_id": afkChannel,
      if (afkTimeout != null) "afk_timeout": afkTimeout,
      if (icon != null) "icon": icon
    };

    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId", method: "PATCH", auditLog: auditReason, body: body));

    if (response is HttpResponseSuccess) {
      return Guild._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  @override
  Future<Member> fetchGuildMember(Snowflake guildId, Snowflake memberId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$memberId"));

    if (response is HttpResponseSuccess) {
      return Member._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  @override
  Stream<Member> fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after}) async* {
    final request = _httpClient._execute(BasicRequest._new("/guilds/$guildId/members",
        queryParams: {"limit": limit.toString(), if (after != null) "after": after.toString()}));

    if (request is HttpResponseError) {
      yield* Stream.error(request);
    }

    for (final rawMember in (request as HttpResponseSuccess)._jsonBody as List<dynamic>) {
      yield Member._new(_client, rawMember as Map<String, dynamic>, guildId);
    }
  }

  @override
  Stream<Member> searchGuildMembers(Snowflake guildId, String query, {int limit = 1}) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/search",
        queryParams: {"query": query, "limit": limit.toString()}));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final Map<String, dynamic> memberData in (response as HttpResponseSuccess)._jsonBody) {
      yield Member._new(_client, memberData, guildId);
    }
  }
  
  @override
  Stream<Webhook> fetchChannelWebhooks(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/webhooks"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody.values) {
      yield Webhook._new(raw as Map<String, dynamic>, _client);
    }
  }

  @override
  Future<void> deleteGuild(Snowflake guildId) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId", method: "DELETE"));

  @override
  Stream<Role> fetchGuildRoles(Snowflake guildId) async* {
    final response = _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawRole in (response as HttpResponseSuccess)._jsonBody.values) {
      yield Role._new(_client, rawRole as Map<String, dynamic>, guildId);
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
  Future<User> fetchUser(Snowflake userId) async {
    final response = await _httpClient._execute(BasicRequest._new("/users/$userId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return User._new(_client, response._jsonBody as Map<String, dynamic>);
  }

  @override
  Future<void> editGuildMember(
      Snowflake guildId,
      Snowflake memberId,
      {String? nick,
        List<SnowflakeEntity>? roles,
        bool? mute,
        bool? deaf,
        SnowflakeEntity? channel,
        String? auditReason}) {
    final body = <String, dynamic>{
      if (nick != null) "nick": nick,
      if (roles != null) "roles": roles.map((f) => f.id.toString()).toList(),
      if (mute != null) "mute": mute,
      if (deaf != null) "deaf": deaf,
      if (channel != null) "channel_id": channel.id.toString()
    };

    return _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$memberId",
        method: "PATCH", auditLog: auditReason, body: body));
  }

  @override
  Future<void> removeRoleFromUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new(
          "/guilds/$guildId/members/$userId/roles/$roleId",
          method: "DELETE",
          auditLog: auditReason));

  @override
  Stream<InviteWithMeta> fetchChannelInvites(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    final bodyValues = (response as HttpResponseSuccess).jsonBody.values.first;

    for (final val in bodyValues as Iterable<Map<String, dynamic>>) {
      yield InviteWithMeta._new(val, _client);
    }
  }

  @override
  Future<void> editChannelPermissions(Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) async {
    final permSet = perms._build();

    await _httpClient._execute(BasicRequest._new("/channels/$channelId/permissions/${entity.id.toString()}",
        method: "PUT", body: {
          "type" : entity is Role ? "role" : "member",
          "allow" : permSet.allow,
          "deny" : permSet.deny
        }, auditLog: auditReason));
  }

  @override
  Future<void> editChannelPermissionOverrides(Snowflake channelId, PermissionOverrideBuilder permissionBuilder, {String? auditReason}) async {
    final permSet = permissionBuilder._build();

    await _httpClient._execute(BasicRequest._new("/channels/$channelId/permissions/${permissionBuilder.id.toString()}",
        method: "PUT", body: {
          "type" : permissionBuilder.type,
          "allow" : permSet.allow,
          "deny" : permSet.deny
        }, auditLog: auditReason));
  }

  @override
  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id, {String? auditReason}) async {
    await _httpClient._execute(BasicRequest._new("/channels/$channelId/permissions/$id", method: "PUT", auditLog: auditReason));
  }
  
  @override
  Future<Invite> createInvite(Snowflake channelId, {int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) async {
    final body = {
      if (maxAge != null) "max_age": maxAge,
      if (maxUses != null) "max_uses": maxUses,
      if (temporary != null) "temporary": temporary,
      if (unique != null) "unique": unique,
    };

    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/invites", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return InviteWithMeta._new((response as HttpResponseSuccess).jsonBody as Map<String, dynamic>, _client);
  }

  @override
  Future<Message> sendMessage(
      Snowflake channelId,
      {dynamic content,
        List<AttachmentBuilder>? files,
        EmbedBuilder? embed,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder,
        ReplyBuilder? replyBuilder
      }) async {
    if (builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      allowedMentions = builder.allowedMentions;
      replyBuilder = builder.replyBuilder;
    }

    final  reqBody = {
      ..._initMessage(content, embed, allowedMentions, replyBuilder),
      if (content != null && tts != null) "tts": tts
    };

    _HttpResponse response;
    if (files != null && files.isNotEmpty) {
      response = await _httpClient
          ._execute(MultipartRequest._new("/channels/$channelId/messages", files, method: "POST", fields: reqBody));
    } else {
      response = await _httpClient
          ._execute(BasicRequest._new("/channels/$channelId/messages", body: reqBody, method: "POST"));
    }

    if (response is HttpResponseSuccess) {
      return Message._deserialize(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }
  
  @override
  Future<Message> fetchMessage(Snowflake channelId, Snowflake messageId) async {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return Message._deserialize(_client, (response as HttpResponseSuccess)._jsonBody as Map<String, dynamic>);
  }

  @override
  Future<void> bulkRemoveMessages(Snowflake channelId, Iterable<SnowflakeEntity> messagesIds) async {
    await for (final chunk in Utils.chunk(messagesIds.toList(), 90)) {
      await _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/bulk-delete",
          method: "POST", body: {"messages": chunk.map((f) => f.id.toString()).toList()}));
    }
  }
  
  @override
  Stream<Message> downloadMessages(Snowflake channelId, {int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around}) async* {
    final queryParams = {
      "limit": limit.toString(),
      if (after != null) "after": after.toString(),
      if (before != null) "before": before.toString(),
      if (around != null) "around": around.toString()
    };

    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/messages", queryParams: queryParams));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final val in await (response as HttpResponseSuccess)._jsonBody) {
      yield Message._deserialize(_client, val as Map<String, dynamic>);
    }
  }

  @override
  Future<VoiceGuildChannel> editVoiceChannel(Snowflake channelId, {String? name, int? bitrate, int? position, int? userLimit, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (bitrate != null) "bitrate": bitrate,
      if (userLimit != null) "user_limit": userLimit,
      if (position != null) "position": position,
    };

    if (body.isEmpty) {
      return Future.error(ArgumentError("Cannot edit channel with empty body"));
    }

    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId", method: "PATCH", body: body, auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return VoiceGuildChannel._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  @override
  Future<Webhook> createWebhook(Snowflake channelId, String name, {File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension, String? auditReason}) async {
    if (name.isEmpty || name.length > 80) {
      return Future.error(ArgumentError("Webhook name cannot be shorter than 1 character and longer than 80 characters"));
    }

    final body = <String, dynamic>{"name": name};

    final uploadString = Utils.getBase64UploadString(file: avatarFile, fileBytes: avatarBytes, base64EncodedFile: encodedAvatar, fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/webhooks", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }

  @override
  Stream<Message> fetchPinnedMessages(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/pins"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final val in (response as HttpResponseSuccess)._jsonBody.values.first as Iterable<Map<String, dynamic>>) {
      yield Message._deserialize(_client, val);
    }
  }

  @override
  Future<TextGuildChannel> editTextChannel(Snowflake channelId, {String? name, String? topic, int? position, int? slowModeThreshold}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (topic != null) "topic": topic,
      if (position != null) "position": position,
      if (slowModeThreshold != null) "rate_limit_per_user": slowModeThreshold,
    };

    if (body.isEmpty) {
      return Future.error(ArgumentError("Cannot edit channel with empty body"));
    }

    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return TextGuildChannel._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }
  
  @override
  Future<void> triggerTyping(Snowflake channelId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/typing", method: "POST"));

  
  @override
  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId) async =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId/crosspost", method: "POST"));

  // TODO: Manage message flags better
  @override
  Future<Message> suppressMessageEmbeds(Snowflake channelId, Snowflake messageId) async {
    final body = <String, dynamic>{
      "flags" : 1 << 2
    };

    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/messages/$messageId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return Message._deserialize(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  @override
  Future<Message> editMessage(
      Snowflake channelId, 
      Snowflake messageId, 
      {dynamic content, 
        EmbedBuilder? embed, 
        AllowedMentions? allowedMentions, 
        MessageEditBuilder? builder
      }) async {
    if (builder != null) {
      content = builder._content;
      embed = builder.embed;
      allowedMentions = builder.allowedMentions;
    }

    final body = <String, dynamic>{
      if (content != null) "content": content.toString(),
      if (embed != null) "embed": embed._build(),
      if (allowedMentions != null) "allowed_mentions": allowedMentions._build(),

    };

    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/messages/$messageId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return Message._deserialize(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  @override
  Future<void> createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me",
          method: "PUT"));

  @override
  Future<void> deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me",
          method: "DELETE"));

  @override
  Future<void> deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/$userId",
          method: "DELETE"));

  @override
  Future<void> deleteMessageAllReactions(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId/reactions", method: "DELETE"));

  @override
  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId, {String? auditReason}) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> pinMessage(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/pins/$messageId", method: "PUT"));

  @override
  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/pins/$messageId", method: "DELETE"));

  @override
  Future<User> editSelfUser({String? username, File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension}) async {
    final body = <String, dynamic>{
      if (username != null) "username": username
    };

    final uploadString = Utils.getBase64UploadString(file: avatarFile, fileBytes: avatarBytes, base64EncodedFile: encodedAvatar, fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient._execute(BasicRequest._new("/users/@me", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return User._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }
  
  @override
  Future<void> deleteInvite(String code, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/invites/$code", method: "DELETE", auditLog: auditReason));

  @override
  Future<void> deleteWebhook(Snowflake id, {String token = "", String? auditReason}) =>
      _httpClient._execute(BasicRequest._new("/webhooks/$id/$token", method: "DELETE", auditLog: auditReason));
  
  @override
  Future<Webhook> editWebhook(Snowflake webhookId, {String token ="", String? name, SnowflakeEntity? channel, File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (channel != null) "channel_id": channel.id.toString()
    };

    final uploadString = Utils.getBase64UploadString(file: avatarFile, fileBytes: avatarBytes, base64EncodedFile: encodedAvatar, fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient
        ._execute(BasicRequest._new("/webhooks/$webhookId/$token", method: "PATCH", auditLog: auditReason, body: body));

    return Future.error(response);
  }

  @override
  Future<Message> executeWebhook(
      Snowflake webhookId,
      { String token = "",
        dynamic content,
        List<AttachmentBuilder>? files,
        List<EmbedBuilder>? embeds,
        bool? tts,
        AllowedMentions? allowedMentions,
        bool? wait,
        String? avatarUrl}) async {
    allowedMentions ??= _client._options.allowedMentions;

    final reqBody = {
      if (content != null) "content": content.toString(),
      if (allowedMentions != null) "allowed_mentions": allowedMentions._build(),
      if(embeds != null) "embeds" : [
        for(final e in embeds)
          e._build()
      ],
      if (content != null && tts != null) "tts": tts,
      if(avatarUrl != null) "avatar_url" : avatarUrl,
    };

    final queryParams = { if(wait != null) "wait" : wait };

    _HttpResponse response;

    if (files != null && files.isNotEmpty) {
      response = await _httpClient
          ._execute(MultipartRequest._new("/webhooks/$webhookId/$token", files, method: "POST", fields: reqBody, queryParams: queryParams));
    } else {
      response = await _httpClient
          ._execute(BasicRequest._new("/webhooks/$webhookId/$token", body: reqBody, method: "POST", queryParams: queryParams));
    }

    if (response is HttpResponseSuccess) {
      return Message._deserialize(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  @override
  Future<Webhook> fetchWebhook(Snowflake id, {String token = ""}) async {
    final response = await _httpClient._execute(BasicRequest._new("/webhooks/$id/$token"));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }

  @override
  Future<Invite> fetchInvite(String code) async {
    final response = await _httpClient._execute(BasicRequest._new("/invites/$code"));

    if (response is HttpResponseSuccess) {
      return Invite._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }
}
