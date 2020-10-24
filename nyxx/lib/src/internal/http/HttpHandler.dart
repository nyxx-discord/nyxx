part of nyxx;

class _HttpClient extends http.BaseClient {
  late final Map<String, String> _authHeader;

  final http.Client _innerClient = http.Client();

  // ignore: public_member_api_docs
  _HttpClient(Nyxx client) {
    this._authHeader = {
     "Authorization" : "Bot ${client._token}"
    };
  }
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(this._authHeader);
    final response = await this._innerClient.send(request);

    if (response.statusCode >= 400) {
      throw HttpClientException(response);
    }

    return response;
  }
}

class HttpClientException extends http.ClientException {
  /// Raw response from server
  final http.BaseResponse? response;

  // ignore: public_member_api_docs
  HttpClientException(this.response) : super("Exception", response?.request?.url);
}

class _HttpHandler {
  final List<_HttpBucket> _buckets = [];
  late final _HttpBucket _noRateBucket;

  final Logger _logger = Logger("Http");
  late final _HttpClient _httpClient;
  final Nyxx client;

  _HttpHandler._new(this.client) {
    this._noRateBucket = _HttpBucket(Uri.parse("noratelimit"), this);
    this._httpClient = _HttpClient(client);
  }

  Future<_HttpResponse> _execute(_HttpRequest request) async {
    request._client = this._httpClient;

    if (!request.rateLimit) {
      return _handle(await this._noRateBucket._execute(request));
    }

    // TODO: NNBD: try-catch in where
    try {
      final bucket = _buckets.firstWhere((element) => element.uri == request.uri);

      return _handle(await bucket._execute(request));
    } on Error {
      final newBucket = _HttpBucket(request.uri, this);
      _buckets.add(newBucket);

      return _handle(await newBucket._execute(request));
    }
  }

  Future<_HttpResponse> _handle(http.StreamedResponse response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseSuccess = HttpResponseSuccess._new(response);
      await responseSuccess._finalize();

      client._events.onHttpResponse.add(HttpResponseEvent._new(responseSuccess));
      return responseSuccess;
    }

    final responseError = HttpResponseError._new(response);
    await responseError._finalize();

    client._events.onHttpError.add(HttpErrorEvent._new(responseError));
    return responseError;
  }
}

class HttpEndpoints {
  late final _HttpHandler _httpClient;
  final Nyxx _client;

  HttpEndpoints._new(this._client) {
    this._httpClient = this._client._http;
  }

  Map<String, dynamic> _initMessage(dynamic content, EmbedBuilder? embed, AllowedMentions? allowedMentions) {
    if (content == null && embed == null) {
      throw ArgumentError("When sending message both content and embed cannot be null");
    }

    allowedMentions ??= _client._options.allowedMentions;

    return <String, dynamic>{
      if (content != null) "content": content.toString(),
      if (embed != null) "embed": embed._build(),
      if (allowedMentions != null) "allowed_mentions": allowedMentions._build()
    };
  }

  String? _getGuildIconUrl(Snowflake guildId, String? iconHash, String format, int size) {
    if (iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/icons/$guildId/$iconHash.$format?size=$size";
    }

    return null;
  }

  String? _getGuildSplashURL(Snowflake guildId, String? splashHash, String format, int size) {
    if (splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/splashes/$guildId/$splashHash.$format?size=$size";
    }

    return null;
  }

  String? _getGuildDiscoveryURL(Snowflake guildId, String? splashHash, {String format = "webp", int size = 128}) {
    if (splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/discovery-splashes/$guildId/$splashHash.$format?size=$size";
    }

    return null;
  }

  String _getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]) =>
      "http://cdn.${Constants.cdnHost}/guilds/$guildId/widget.png?style=$style";

  Future<GuildEmoji> _editGuildEmoji(Snowflake guildId, Snowflake emojiId, {String? name, List<Snowflake>? roles}) async {
    if (name == null && roles == null) {
      return Future.error(ArgumentError("Both name and roles fields cannot be null"));
    }

    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString())
    };

    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/$guildId/emojis/$emojiId", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  Future<void> _deleteGuildEmoji(Snowflake guildId, Snowflake emojiId) async =>
      _httpClient._execute(
          BasicRequest._new("/guilds/$guildId/emojis/$emojiId", method: "DELETE"));

  /// Edits the role.
  Future<RoleNew> _editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role, {String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles/$roleId",
        method: "PATCH", body: role._build(), auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return RoleNew._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  Future<void> _deleteRole(Snowflake guildId, Snowflake roleId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles/$roleId", method: "DELETE", auditLog: auditReason));

  Future<void> _addRoleToUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$userId/roles/$roleId", method: "PUT", auditLog: auditReason));

  Future<GuildNew> _fetchGuild(Snowflake guildId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId"));

    if (response is HttpResponseSuccess) {
      return GuildNew._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  Future<T> _fetchChannel<T>(Snowflake id) async {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$id"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    final raw = (response as HttpResponseSuccess)._jsonBody as Map<String, dynamic>;
    return IChannel._deserialize(_client, raw) as T;
  }

  Future<IGuildEmoji> _fetchGuildEmoji(Snowflake guildId, Snowflake emojiId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/emojis/$emojiId"));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  Future<GuildEmoji> _createEmoji(Snowflake guildId, String name, {List<SnowflakeEntity>? roles, File? image, List<int>? imageBytes}) async {
    if (image != null && await image.length() > 256000) {
      return Future.error(ArgumentError("Emojis and animated emojis have a maximum file size of 256kb."));
    }

    if (image == null && imageBytes == null) {
      return Future.error(ArgumentError("Both imageData and file fields cannot be null"));
    }

    final body = <String, dynamic>{
      "name": name,
      "image": base64.encode(image == null ? imageBytes! : await image.readAsBytes()),
      if (roles != null) "roles": roles.map((r) => r.id.toString())
    };

    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/emojis", method: "POST", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  Future<int> _guildPruneCount(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles}) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/prune", queryParams: {
      "days": days.toString(),
      if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())
    }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  Future<int> _guildPrune(Snowflake guildId, int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) async {
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

  Stream<Ban> _getGuildBans(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final obj in (response as HttpResponseSuccess)._jsonBody) {
      yield Ban._new(obj as Map<String, dynamic>, _client);
    }
  }

  /// Change self nickname in guild
  Future<void> _changeGuildSelfNick(Snowflake guildId, String nick) async =>
      _httpClient._execute(
          BasicRequest._new("/guilds/$guildId/members/@me/nick", method: "PATCH", body: {"nick": nick}));

  Future<Ban> _getGuildBan(Snowflake guildId, Snowflake bannedUserId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$bannedUserId"));

    if (response is HttpResponseSuccess) {
      return Ban._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }

  Future<GuildNew> _changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason}) async {
    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/$guildId", method: "PATCH", auditLog: auditReason, body: {"owner_id": member.id}));

    if (response is HttpResponseSuccess) {
      return GuildNew._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }
  
  Future<void> _leaveGuild(Snowflake guildId) async =>
      _httpClient._execute(BasicRequest._new("/users/@me/guilds/$guildId", method: "DELETE"));

  Stream<Invite> _fetchGuildInvites(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield Invite._new(raw as Map<String, dynamic>, _client);
    }
  }

  Future<AuditLog> _fetchAuditLogs(Snowflake guildId, {Snowflake? userId, int? actionType, Snowflake? before, int? limit}) async {
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

  Future<RoleNew> _createGuildRole(Snowflake guildId, RoleBuilder roleBuilder, {String? auditReason}) async {
    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/$guildId/roles", method: "POST", auditLog: auditReason, body: roleBuilder._build()));

    if (response is HttpResponseSuccess) {
      return RoleNew._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  Stream<VoiceRegion> _fetchGuildVoiceRegions(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/regions"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield VoiceRegion._new(raw as Map<String, dynamic>);
    }
  }

  Future<void> _moveGuildChannel(Snowflake guildId, Snowflake channelId, int position, {String? auditReason}) async {
    await _httpClient._execute(BasicRequest._new("/guilds/$guildId/channels",
        method: "PATCH", auditLog: auditReason, body: {"id": channelId.toString(), "position": position}));
  }

  Future<void> _guildBan(Snowflake guildId, Snowflake userId, {int deleteMessageDays = 0, String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$userId",
          method: "PUT", auditLog: auditReason, body: {"delete-message-days": deleteMessageDays}));

  Future<void> _guildKick(Snowflake guildId, Snowflake userId, {String? auditReason}) async =>
    _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$userId",
        method: "DELTE", auditLog: auditReason));

  Future<void> _guildUnban(Snowflake guildId, Snowflake userId) async =>
    _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$userId", method: "DELETE"));

   Future<GuildNew> _editGuild(
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
      return GuildNew._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  Future<Member> _fetchGuildMember(Snowflake guildId, Snowflake memberId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$memberId"));

    if (response is HttpResponseSuccess) {
      return Member._new(_client, response.jsonBody as Map<String, dynamic>, guildId);
    }

    return Future.error(response);
  }

  Stream<Member> _fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after}) async* {
    final request = _httpClient._execute(BasicRequest._new("/guilds/$guildId/members",
        queryParams: {"limit": limit.toString(), if (after != null) "after": after.toString()}));

    if (request is HttpResponseError) {
      yield* Stream.error(request);
    }

    for (final rawMember in (request as HttpResponseSuccess)._jsonBody as List<dynamic>) {
      yield Member._new(_client, rawMember as Map<String, dynamic>, guildId);
    }
  }

  Stream<Member> _searchGuildMembers(Snowflake guildId, String query, {int limit = 1}) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/search",
        queryParams: {"query": query, "limit": limit.toString()}));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final Map<String, dynamic> memberData in (response as HttpResponseSuccess)._jsonBody) {
      yield Member._new(_client, memberData, guildId);
    }
  }

  Stream<Webhook> _fetchChannelWebhooks(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/webhooks"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody.values) {
      yield Webhook._new(raw as Map<String, dynamic>, _client);
    }
  }

  Future<void> _deleteGuild(Snowflake guildId) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId", method: "DELETE"));

   Stream<RoleNew> _fetchGuildRoles(Snowflake guildId) async* {
     final response = _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles"));

     if (response is HttpResponseError) {
       yield* Stream.error(response);
     }

     for (final rawRole in (response as HttpResponseSuccess)._jsonBody.values) {
       yield RoleNew._new(_client, rawRole as Map<String, dynamic>, guildId);
     }
   }

  String _userAvatarURL(Snowflake userId, String? avatarHash, int discriminator, {String format = "webp", int size = 128}) {
    if (avatarHash != null) {
      return "https://cdn.${Constants.cdnHost}/avatars/$userId/$avatarHash.$format?size=$size";
    }

    return "https://cdn.${Constants.cdnHost}/embed/avatars/${discriminator % 5}.png?size=$size";
  }

  Future<User> _fetchUser(Snowflake userId) async {
     final response = await _httpClient._execute(BasicRequest._new("/users/$userId"));

     if (response is HttpResponseError) {
       return Future.error(response);
     }

     return User._new(_client, response._jsonBody as Map<String, dynamic>);
   }

  Future<void> _editGuildMember(
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

  Future<void> _removeRoleFromUser(Snowflake guildId, Snowflake roleId, Snowflake userId, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new(
          "/guilds/$guildId/members/$userId/roles/$roleId",
          method: "DELETE",
          auditLog: auditReason));

  Stream<InviteWithMeta> _fetchChannelInvites(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    final bodyValues = (response as HttpResponseSuccess).jsonBody.values.first;

    for (final val in bodyValues as Iterable<Map<String, dynamic>>) {
      yield InviteWithMeta._new(val, _client);
    }
  }

  Future<void> _editChannelPermissions(Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) async {
    final permSet = perms._build();

    await _httpClient._execute(BasicRequest._new("/channels/$channelId/permissions/${entity.id.toString()}",
        method: "PUT", body: {
          "type" : entity is RoleNew ? "role" : "member",
          "allow" : permSet.allow,
          "deny" : permSet.deny
        }, auditLog: auditReason));
  }

  Future<void> _editChannelPermissionOverrides(Snowflake channelId, PermissionOverrideBuilder permissionBuilder, {String? auditReason}) async {
    final permSet = permissionBuilder._build();

    await _httpClient._execute(BasicRequest._new("/channels/$channelId/permissions/${permissionBuilder.id.toString()}",
        method: "PUT", body: {
          "type" : permissionBuilder.type,
          "allow" : permSet.allow,
          "deny" : permSet.deny
        }, auditLog: auditReason));
  }

  Future<void> _deleteChannelPermission(Snowflake channelId, SnowflakeEntity id, {String? auditReason}) async {
    await _httpClient._execute(BasicRequest._new("/channels/$channelId/permissions/$id", method: "PUT", auditLog: auditReason));
  }

  Future<Invite> _createInvite(Snowflake channelId, {int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) async {
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

  Future<Message> _sendMessage(
      Snowflake channelId,
      {dynamic content,
        List<AttachmentBuilder>? files,
        EmbedBuilder? embed,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder}) async {
    if (builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      allowedMentions = builder.allowedMentions;
    }

    final  reqBody = {
      ..._initMessage(content, embed, allowedMentions),
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

  Future<Message> _fetchMessage(Snowflake channelId, Snowflake messageId) async {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return Message._deserialize(_client, (response as HttpResponseSuccess)._jsonBody as Map<String, dynamic>);
  }

  Future<void> _bulkRemoveMessages(Snowflake channelId, Iterable<SnowflakeEntity> messagesIds) async {
    await for (final chunk in Utils.chunk(messagesIds.toList(), 90)) {
      await _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/bulk-delete",
          method: "POST", body: {"messages": chunk.map((f) => f.id.toString()).toList()}));
    }
  }

  Stream<Message> _downloadMessages(Snowflake channelId, {int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around}) async* {
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

  Future<VoiceGuildChannel> _editVoiceChannel(Snowflake channelId, {String? name, int? bitrate, int? position, int? userLimit, String? auditReason}) async {
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

  Future<Webhook> _createWebhook(Snowflake channelId, String name, {File? avatarFile, String? auditReason}) async {
    if (name.isEmpty || name.length > 80) {
      return Future.error(ArgumentError("Webhook name cannot be shorter than 1 character and longer than 80 characters"));
    }

    final body = <String, dynamic>{"name": name};

    if (avatarFile != null) {
      final extension = Utils.getFileExtension(avatarFile.path);
      final data = base64Encode(await avatarFile.readAsBytes());

      body["avatar"] = "data:image/$extension;base64,$data";
    }

    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/webhooks", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }

  Stream<Message> _fetchPinnedMessages(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/pins"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final val in (response as HttpResponseSuccess)._jsonBody.values.first as Iterable<Map<String, dynamic>>) {
      yield Message._deserialize(_client, val);
    }
  }

  Future<TextGuildChannel> _editTextChannel(Snowflake channelId, {String? name, String? topic, int? position, int? slowModeThreshold}) async {
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

  Future<void> _triggerTyping(Snowflake channelId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/typing", method: "POST"));


  Future<void> _crossPostGuildMessage(Snowflake channelId, Snowflake messageId) async =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId/crosspost", method: "POST"));

  // TODO: Manage message flags better
  Future<Message> _suppressMessageEmbeds(Snowflake channelId, Snowflake messageId) async {
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

  Future<Message> _editMessage(Snowflake channelId, Snowflake messageId, {dynamic content, EmbedBuilder? embed, AllowedMentions? allowedMentions, MessageEditBuilder? builder}) async {
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

  Future<void> _createMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me",
          method: "PUT"));

  Future<void> _deleteMessageReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me",
          method: "DELETE"));

  Future<void> _deleteMessageUserReaction(Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/$userId",
          method: "DELETE"));

  Future<void> _deleteMessageAllReactions(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId/reactions", method: "DELETE"));

  Future<void> _deleteMessage(Snowflake channelId, Snowflake messageId, {String? auditReason}) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId", method: "DELETE", auditLog: auditReason));

  Future<void> _pinMessage(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/pins/$messageId", method: "PUT"));

  Future<void> _unpinMessage(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new("/channels/$channelId/pins/$messageId", method: "DELETE"));

  Future<User> _editSelfUser({String? username, File? avatar, String? encodedAvatar}) async {
    if (username == null && (avatar == null || encodedAvatar == null)) {
      return Future.error(ArgumentError("Cannot edit user with null null arguments"));
    }

    final body = <String, dynamic>{
      if (username != null) "username": username
    };

    final base64Encoded = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedAvatar;
    body["avatar"] = "data:image/jpeg;base64,$base64Encoded";

    final response = await _httpClient._execute(BasicRequest._new("/users/@me", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return User._new(_client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  Future<void> _deleteInvite(String code, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/invites/$code", method: "DELETE", auditLog: auditReason));

  Future<void> _deleteWebhook(Snowflake id, {String token = "", String? auditReason}) =>
      _httpClient._execute(BasicRequest._new("/webhooks/$id/$token", method: "DELETE", auditLog: auditReason));

  Future<Webhook> _editWebhook(Snowflake webhookId, {String token ="", String? name, SnowflakeEntity? channel, File? avatar, String? encodedAvatar, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (channel != null) "channel_id": channel.id.toString()
    };

    final base64Encoded = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedAvatar;
    body["avatar"] = "data:image/jpeg;base64,$base64Encoded";

    final response = await _httpClient
        ._execute(BasicRequest._new("/webhooks/$webhookId/$token", method: "PATCH", auditLog: auditReason, body: body));

    return Future.error(response);
  }

  Future<Message> _executeWebhook(
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

  Future<Webhook> _fetchWebhook(Snowflake id, {String token = ""}) async {
    final response = await _httpClient._execute(BasicRequest._new("/webhooks/$id/$token"));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }

  Future<Invite> _fetchInvite(String code) async {
    final response = await _httpClient._execute(BasicRequest._new("/invites/$code"));

    if (response is HttpResponseSuccess) {
      return Invite._new(response.jsonBody as Map<String, dynamic>, _client);
    }

    return Future.error(response);
  }
}

class _HttpBucket {
  // Rate limits
  int remaining = 10;
  DateTime? resetAt;
  int? resetAfter;

  // Bucket uri
  late final Uri uri;

  // Reference to http handler
  final _HttpHandler _httpHandler;

  _HttpBucket(this.uri, this._httpHandler);

  Future<http.StreamedResponse> _execute(_HttpRequest request) async {
    // Get actual time and check if request can be executed based on data that bucket already have
    // and wait if rate limit could be possibly hit
    final now = DateTime.now();
    if ((resetAt != null && resetAt!.isAfter(now)) && remaining < 2) {
      final waitTime = resetAt!.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

      if (waitTime > 0) {
        _httpHandler.client._events.onRatelimited.add(RatelimitEvent._new(request, true));
        _httpHandler._logger.warning(
            "Rate limited internally on endpoint: ${request.uri}. Trying to send request again in $waitTime ms...");

        return Future.delayed(Duration(milliseconds: waitTime), () => _execute(request));
      }
    }

    // Execute request
    try {
      final response = await request._execute();

      _setBucketValues(response.headers);
      return response;
    } on HttpClientException catch (e) {
      if (e.response == null) {
        _httpHandler._logger.warning("Http Error on endpoint: ${request.uri}. Error: [${e.message.toString()}].");
        return Future.delayed(const Duration(milliseconds: 1000), () => _execute(request));
      }

      final response = e.response as http.StreamedResponse;

      // Check for 429, emmit events and wait given in response body time
      if (response.statusCode == 429) {
        final responseBody = jsonDecode(await response.stream.bytesToString());
        final retryAfter = responseBody["retry_after"] as int;

        _httpHandler.client._events.onRatelimited.add(RatelimitEvent._new(request, false, response));
        _httpHandler._logger.warning(
            "Rate limited via 429 on endpoint: ${request.uri}. Trying to send request again in $retryAfter ms...");

        return Future.delayed(Duration(milliseconds: retryAfter), () => _execute(request));
      }

      // Return http error
      _setBucketValues(response.headers);
      return response;
    }
  }

  void _setBucketValues(Map<String, String> headers) {
    if (headers["x-ratelimit-remaining"] != null) {
      this.remaining = int.parse(headers["x-ratelimit-remaining"]!);
    }

    // seconds since epoch
    if (headers["x-ratelimit-reset"] != null) {
      final secondsSinceEpoch = int.parse(headers["x-ratelimit-reset"]!) * 1000;
      this.resetAt = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch);
    }

    if (headers["x-ratelimit-reset-after"] != null) {
      this.resetAfter = int.parse(headers["x-ratelimit-reset-after"]!);
    }
  }
}
