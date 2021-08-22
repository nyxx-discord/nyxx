part of nyxx_interactions;

abstract class IInteractionsEndpoints {
  Future<Message> sendFollowup(String token, String interactionId, MessageBuilder builder);
  Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode);
  Future<void> respondEditOriginal(String token, String interactionId, MessageBuilder builder, bool hidden);
  Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode);
  Future<Message> fetchOriginalResponse(String token, String interactionId);
  Future<Message> editOriginalResponse(String token, String interactionId, MessageBuilder builder);
  Future<void> deleteOriginalResponse(String token, String interactionId);
  Future<void> deleteFollowup(String token, String interactionId, Snowflake messageId);
  Future<Message> editFollowup(String token, String interactionId, MessageBuilder builder);
  Stream<SlashCommand> fetchGlobalCommands(Snowflake applicationId);
  Future<SlashCommand> fetchGlobalCommand(Snowflake applicationId, Snowflake commandId);
  Future<SlashCommand> editGlobalCommand(Snowflake applicationId, Snowflake commandId, SlashCommandBuilder builder);
  Future<void> deleteGlobalCommand(Snowflake applicationId, Snowflake commandId);
  Stream<SlashCommand> bulkOverrideGlobalCommands(Snowflake applicationId, Iterable<SlashCommandBuilder> builders);
  Stream<SlashCommand> fetchGuildCommands(Snowflake applicationId, Snowflake guildId);
  Future<SlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);
  Future<SlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder);
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);
  Stream<SlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);
  Future<void> bulkOverrideGlobalCommandsPermissions(Snowflake applicationId, Iterable<SlashCommandBuilder> builders);
}

class _InteractionsEndpoints implements IInteractionsEndpoints {
  final Nyxx _client;

  _InteractionsEndpoints(this._client);

  @override
  Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode) async {
   final url = "/interactions/$interactionId/$token/callback";
   final response = await this._client.httpEndpoints.sendRawRequest(url, "POST", body: {
    "type": opCode,
    "data": {
     if (hidden) "flags": 1 << 6,
    }
   });

   if (response is HttpResponseError) {
    return Future.error(response);
   }
  }

  @override
  Future<void> deleteFollowup(String token, String interactionId, Snowflake messageId) =>
      this._client.httpEndpoints.sendRawRequest(
        "webhooks/$interactionId/$token/messages/$messageId",
        "DELETE"
      );

  @override
  Future<void> deleteOriginalResponse(String token, String interactionId) async {
    final url = "/webhooks/${interactionId.toString()}/$token/messages/@original";
    const method = "DELETE";

    final response = await this._client.httpEndpoints.sendRawRequest(url, method);
    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<Message> editFollowup(String token, String interactionId, MessageBuilder builder) async {
    final url = "/webhooks/${interactionId.toString()}/$token";
    final body = BuilderUtility.buildWithClient(builder, _client);

    final response = await this._client.httpEndpoints.sendRawRequest(url, "PATCH", body: body);
    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<Message> editOriginalResponse(String token, String interactionId, MessageBuilder builder) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/webhooks/${interactionId.toString()}/$token/messages/@original",
        "PATCH",
        body: builder.build(this._client)
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<Message> fetchOriginalResponse(String token, String interactionId) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/webhooks/${interactionId.toString()}/$token/messages/@original",
        "GET"
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> respondEditOriginal(String token, String interactionId, MessageBuilder builder, bool hidden) async {
   final url = "/webhooks/${interactionId.toString()}/$token/messages/@original";
   final body = {
    if (hidden) "flags": 1 << 6,
    ...BuilderUtility.buildWithClient(builder, _client)
   };
   const method = "PATCH";

   final response = await this._client.httpEndpoints.sendRawRequest(url, method, body: body);
   if (response is HttpResponseError) {
    return Future.error(response);
   }
  }

  @override
  Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode) async {
   final url = "/interactions/${interactionId.toString()}/$token/callback";
   final body = <String, dynamic>{
    "type": respondOpCode,
    "data": {
     if (hidden) "flags": 1 << 6,
     ...BuilderUtility.buildWithClient(builder, _client)
    },
   };
   const method = "POST";

   final response = await this._client.httpEndpoints.sendRawRequest(url, method, body: body);
   if (response is HttpResponseError) {
    return Future.error(response);
   }
  }

  @override
  Future<Message> sendFollowup(String token, String interactionId, MessageBuilder builder) async {
    final url = "/webhooks/${interactionId.toString()}/$token";
    final body = BuilderUtility.buildWithClient(builder, _client);

    final response = await this._client.httpEndpoints.sendRawRequest(url, "POST", body: body);
    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Stream<SlashCommand> bulkOverrideGlobalCommands(Snowflake applicationId, Iterable<SlashCommandBuilder> builders) async* {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/commands",
        "PUT",
        body: [
          for(final builder in builders)
            builder.build()
        ]
    );

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawRes in (response as HttpResponseSuccess).jsonBody as List<dynamic>) {
      yield SlashCommand._new(rawRes as RawApiMap, this._client);
    }
  }

  @override
  Stream<SlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders) async* {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/${this._client.app.id}/guilds/$guildId/commands",
        "PUT",
        body: [
          for(final builder in builders)
            builder.build()
        ]
    );

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawRes in (response as HttpResponseSuccess).jsonBody as List<dynamic>) {
      yield SlashCommand._new(rawRes as RawApiMap, this._client);
    }
  }

  @override
  Future<void> deleteGlobalCommand(Snowflake applicationId, Snowflake commandId) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/commands/$commandId",
        "DELETE"
    );

    if (response is HttpResponseSuccess) {
      return Future.error(response);
    }
  }

  @override
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/guilds/$guildId/commands/$commandId",
        "DELETE"
    );

    if (response is HttpResponseSuccess) {
      return Future.error(response);
    }
  }

  @override
  Future<SlashCommand> editGlobalCommand(Snowflake applicationId, Snowflake commandId, SlashCommandBuilder builder) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/commands/$commandId",
        "PATCH",
        body: builder.build()
    );

    if (response is HttpResponseSuccess) {
      return Future.error(response);
    }

    return SlashCommand._new((response as HttpResponseSuccess).jsonBody as RawApiMap, _client);
  }

  @override
  Future<SlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/guilds/$guildId/commands/$commandId",
        "GET",
        body: builder.build()
    );

    if (response is HttpResponseSuccess) {
      return Future.error(response);
    }

    return SlashCommand._new((response as HttpResponseSuccess).jsonBody as RawApiMap, _client);
  }

  @override
  Future<SlashCommand> fetchGlobalCommand(Snowflake applicationId, Snowflake commandId) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/commands/$commandId",
        "GET"
    );

    if (response is HttpResponseSuccess) {
      return Future.error(response);
    }

    return SlashCommand._new((response as HttpResponseSuccess).jsonBody as RawApiMap, _client);
  }

  @override
  Stream<SlashCommand> fetchGlobalCommands(Snowflake applicationId) async* {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/commands",
        "GET"
    );

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final commandSlash in (response as HttpResponseSuccess).jsonBody as List<dynamic>) {
      yield SlashCommand._new(commandSlash as RawApiMap, _client);
    }
  }

  @override
  Future<SlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/applications/$applicationId/guilds/$guildId/commands/$commandId",
        "GET"
    );

    if (response is HttpResponseSuccess) {
      return Future.error(response);
    }

    return SlashCommand._new((response as HttpResponseSuccess).jsonBody as RawApiMap, _client);
  }

  @override
  Stream<SlashCommand> fetchGuildCommands(Snowflake applicationId, Snowflake guildId) async* {
    final response = await this._client.httpEndpoints.sendRawRequest(
      "/applications/$applicationId/guilds/$guildId/commands",
      "GET"
    );

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final commandSlash in (response as HttpResponseSuccess).jsonBody as List<dynamic>) {
      yield SlashCommand._new(commandSlash as RawApiMap, _client);
    }
  }

  @override
  Future<void> bulkOverrideGlobalCommandsPermissions(Snowflake applicationId, Iterable<SlashCommandBuilder> builders) async {
    final globalBody = builders
        .where((builder) => builder.permissions != null && builder.permissions!.isNotEmpty)
        .map((builder) => {
          "id": builder._id.toString(),
          "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
        })
        .toList();

    await this._client.httpEndpoints
        .sendRawRequest("/applications/$applicationId/commands/permissions", "PUT", body: globalBody);
  }

  @override
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders) async {
    final guildBody = builders
        .where((b) => b.permissions != null && b.permissions!.isNotEmpty)
        .map((builder) => {
          "id": builder._id.toString(),
          "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
        })
        .toList();

    await this._client.httpEndpoints
        .sendRawRequest("/applications/$applicationId/guilds/$guildId/commands/permissions", "PUT", body: guildBody);

  }
}
