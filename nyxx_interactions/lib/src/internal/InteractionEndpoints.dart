part of nyxx_interactions;

abstract class IInteractionsEndpoints {
 Future<Message> sendFollowup(String token, String interactionId, MessageBuilder builder);
 Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode);
 Future<void> respondEditOriginal(String token, String interactionId, MessageBuilder builder, bool hidden);
 Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode);
 Future<Message> getOriginalResponse(String token, String interactionId);
 Future<Message> editOriginalResponse(String token, String interactionId, MessageBuilder builder);
 Future<void> deleteOriginalResponse(String token, String interactionId);
 Future<void> deleteFollowup(String token, String interactionId, Snowflake messageId);
 Future<Message> editFollowup(String token, String interactionId, MessageBuilder builder);
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
  Future<Message> getOriginalResponse(String token, String interactionId) async {
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
}
