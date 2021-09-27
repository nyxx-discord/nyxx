part of nyxx_interactions;

abstract class IInteractionsEndpoints {
  /// Sends followup for interaction with given [token]. Message will be created with [builder]
  Future<Message> sendFollowup(String token, Snowflake applicationId, MessageBuilder builder);

  /// Fetches followup messagge from API
  Future<Message> fetchFollowup(String token, Snowflake applicationId, Snowflake messageId);

  /// Acknowledges interaction that response can be sent within next 15 mins.
  /// Response will be ephemeral if [hidden] is set to true. To response to different interaction types
  /// (slash command, button...) [opCode] is used.
  Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode);

  /// Response to interaction by editing original response. Used when interaction was acked before.
  Future<void> respondEditOriginal(String token, Snowflake applicationId, MessageBuilder builder, bool hidden);

  /// Response to interaction by creating response. Used when interaction wasn't acked before.
  Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode);

  /// Fetch original interaction response.
  Future<Message> fetchOriginalResponse(String token, Snowflake applicationId, String interactionId);

  /// Edits original interaction response using [builder]
  Future<Message> editOriginalResponse(String token, Snowflake applicationId, MessageBuilder builder);

  /// Deletes original interaction response
  Future<void> deleteOriginalResponse(String token, Snowflake applicationId, String interactionId);

  /// Deletes followup message with given id
  Future<void> deleteFollowup(String token, Snowflake applicationId, Snowflake messageId);

  /// Edits followup message with given [messageId]
  Future<Message> editFollowup(String token, Snowflake applicationId, Snowflake messageId, MessageBuilder builder);

  /// Fetches global commands of application
  Stream<SlashCommand> fetchGlobalCommands(Snowflake applicationId);

  /// Fetches global command with given [commandId]
  Future<SlashCommand> fetchGlobalCommand(Snowflake applicationId, Snowflake commandId);

  /// Edits global command with given [commandId] using [builder]
  Future<SlashCommand> editGlobalCommand(Snowflake applicationId, Snowflake commandId, SlashCommandBuilder builder);

  /// Deletes global command with given [commandId]
  Future<void> deleteGlobalCommand(Snowflake applicationId, Snowflake commandId);

  /// Bulk overrides global commands. To delete all apps global commands pass empty list to [builders]
  Stream<SlashCommand> bulkOverrideGlobalCommands(Snowflake applicationId, Iterable<SlashCommandBuilder> builders);

  /// Fetches all commands for given [guildId]
  Stream<SlashCommand> fetchGuildCommands(Snowflake applicationId, Snowflake guildId);

  /// Fetches single guild command with given [commandId]
  Future<SlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);

  /// Edits single guild command with given [commandId]
  Future<SlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder);

  /// Deletes guild command with given commandId]
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);

  /// Bulk overrides global commands. To delete all apps global commands pass empty list to [builders]
  Stream<SlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);

  /// Overrides permissions for guild commands
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);

  /// Overrides permissions for global commands
  Future<void> bulkOverrideGlobalCommandsPermissions(Snowflake applicationId, Iterable<SlashCommandBuilder> builders);

  /// Responds to autocomplete interaction
  Future<void> respondToAutocomplete(Snowflake interactionId, String token, List<ArgChoiceBuilder> builders);
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
  Future<void> deleteFollowup(String token, Snowflake applicationId, Snowflake messageId) =>
      this._client.httpEndpoints.sendRawRequest(
        "webhooks/$applicationId/$token/messages/$messageId",
        "DELETE"
      );

  @override
  Future<void> deleteOriginalResponse(String token, Snowflake applicationId, String interactionId) async {
    final url = "/webhooks/$applicationId/$token/messages/@original";
    const method = "DELETE";

    final response = await this._client.httpEndpoints.sendRawRequest(url, method);
    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<Message> editFollowup(String token, Snowflake applicationId, Snowflake messageId, MessageBuilder builder) async {
    final url = "/webhooks/$applicationId/$token/messages/$messageId";
    final body = BuilderUtility.buildWithClient(builder, _client);

    final response = await this._client.httpEndpoints.sendRawRequest(url, "PATCH", body: body);
    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<Message> editOriginalResponse(String token, Snowflake applicationId, MessageBuilder builder) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/webhooks/$applicationId/$token/messages/@original",
        "PATCH",
        body: builder.build(this._client)
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<Message> fetchOriginalResponse(String token, Snowflake applicationId, String interactionId) async {
    final response = await this._client.httpEndpoints.sendRawRequest(
        "/webhooks/$applicationId/$token/messages/@original",
        "GET"
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return EntityUtility.createMessage(this._client, (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> respondEditOriginal(String token, Snowflake applicationId, MessageBuilder builder, bool hidden) async {
   final url = "/webhooks/$applicationId/$token/messages/@original";
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
  Future<Message> sendFollowup(String token, Snowflake applicationId, MessageBuilder builder) async {
    final url = "/webhooks/$applicationId/$token";
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

  @override
  Future<Message> fetchFollowup(String token, Snowflake applicationId, Snowflake messageId) async {
    final result = await this._client.httpEndpoints.sendRawRequest(
        "/webhooks/$applicationId/$token/messages/${messageId.toString()}",
        "GET"
    );

    if (result is HttpResponseError) {
      return Future.error(result);
    }

    return EntityUtility.createMessage(_client, (result as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<void> respondToAutocomplete(Snowflake interactionId, String token, List<ArgChoiceBuilder> builders) async {
    final result = await this._client.httpEndpoints.sendRawRequest(
      "/interactions/${interactionId.toString()}/$token/callback",
      "POST",
      body: {
        "type": 8,
        "data": {
           "choices": [
             for (final builder in builders)
               builder.build()
           ]
        }
      }
    );

    if (result is HttpResponseError) {
      return Future.error(result);
    }
  }
}
