import 'dart:convert';

import 'package:http/http.dart' hide MultipartRequest;

import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/builders/webhook.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class WebhookManager extends Manager<Webhook> {
  WebhookManager(super.config, super.client);

  @override
  PartialWebhook operator [](Snowflake id) => PartialWebhook(id: id, manager: this);

  @override
  Webhook parse(Map<String, Object?> raw) {
    return Webhook(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      type: WebhookType.parse(raw['type'] as int),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      user: maybeParse(raw['user'], client.users.parse),
      name: raw['name'] as String?,
      avatarHash: raw['avatar'] as String?,
      token: raw['token'] as String?,
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      sourceChannel: maybeParse(
        raw['source_chanel'],
        (Map<String, Object?> raw) => PartialChannel(
          id: Snowflake.parse(raw['id'] as String),
          manager: client.channels,
        ),
      ),
      url: maybeParse(raw['url'], Uri.parse),
    );
  }

  @override
  Future<Webhook> fetch(Snowflake id, {String? token}) async {
    final route = HttpRoute()..webhooks(id: id.toString());
    if (token != null) {
      route.add(HttpRoutePart(token));
    }
    final request = BasicRequest(route, authenticated: token == null);

    final response = await client.httpHandler.executeSafe(request);
    final webhook = parse(response.jsonBody as Map<String, Object?>);

    cache[webhook.id] = webhook;
    return webhook;
  }

  @override
  Future<Webhook> create(WebhookBuilder builder) async {
    final route = HttpRoute()..channels(id: builder.channelId.toString());
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final webhook = parse(response.jsonBody as Map<String, Object?>);

    cache[webhook.id] = webhook;
    return webhook;
  }

  @override
  Future<Webhook> update(Snowflake id, WebhookUpdateBuilder builder, {String? token}) async {
    final route = HttpRoute()..webhooks(id: id.toString());
    if (token != null) {
      route.add(HttpRoutePart(token));
    }
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()), authenticated: token == null);

    final response = await client.httpHandler.executeSafe(request);
    final webhook = parse(response.jsonBody as Map<String, Object?>);

    cache[webhook.id] = webhook;
    return webhook;
  }

  @override
  Future<void> delete(Snowflake id, {String? token}) async {
    final route = HttpRoute()..webhooks(id: id.toString());
    if (token != null) {
      route.add(HttpRoutePart(token));
    }
    final request = BasicRequest(route, method: 'DELETE', authenticated: token == null);

    await client.httpHandler.executeSafe(request);

    cache.remove(id);
  }

  Future<List<Webhook>> fetchChannelWebhooks(Snowflake channelId) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..webhooks();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final webhooks = parseMany(response.jsonBody as List, parse);

    cache.addEntries(webhooks.map((webhook) => MapEntry(webhook.id, webhook)));
    return webhooks;
  }

  Future<List<Webhook>> fetchGuildWebhooks(Snowflake guildId) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..webhooks();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final webhooks = parseMany(response.jsonBody as List, parse);

    cache.addEntries(webhooks.map((webhook) => MapEntry(webhook.id, webhook)));
    return webhooks;
  }

  Future<Message?> execute(Snowflake id, MessageBuilder builder, {required String token, bool? wait, Snowflake? threadId}) async {
    final route = HttpRoute()
      ..webhooks(id: id.toString())
      ..add(HttpRoutePart(token));

    final queryParameters = {if (wait != null) 'wait': wait.toString(), if (threadId != null) 'thread_id': threadId.toString()};
    final HttpRequest request;
    if (!identical(builder.attachments, sentinelList) && builder.attachments?.isNotEmpty == true) {
      final attachments = builder.attachments!;
      final payload = builder.build();

      final files = <MultipartFile>[];
      for (int i = 0; i < attachments.length; i++) {
        files.add(MultipartFile.fromBytes(
          'files[$i]',
          attachments[i].data,
          filename: attachments[i].fileName,
        ));

        ((payload['attachments'] as List)[i] as Map)['id'] = i.toString();
      }

      request = MultipartRequest(
        route,
        method: 'POST',
        jsonPayload: jsonEncode(payload),
        files: files,
        queryParameters: queryParameters,
        authenticated: false,
      );
    } else {
      request = BasicRequest(
        route,
        method: 'POST',
        body: jsonEncode(builder.build()),
        queryParameters: queryParameters,
        authenticated: false,
      );
    }

    final response = await client.httpHandler.executeSafe(request);

    if (wait != true) {
      return null;
    }

    final messageManager = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse((response.jsonBody as Map<String, Object?>)['channel_id'] as String),
    );
    final message = messageManager.parse(response.jsonBody as Map<String, Object?>);

    messageManager.cache[message.id] = message;
    return message;
  }

  Future<Message> fetchWebhookMessage(Snowflake webhookId, Snowflake messageId, {required String token, Snowflake? threadId}) async {
    final route = HttpRoute()
      ..webhooks(id: webhookId.toString())
      ..add(HttpRoutePart(token))
      ..messages(id: messageId.toString());
    final request = BasicRequest(
      route,
      queryParameters: {if (threadId != null) 'thread_id': threadId.toString()},
      authenticated: false,
    );

    final response = await client.httpHandler.executeSafe(request);
    final messageManager = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse((response.jsonBody as Map<String, Object?>)['channel_id'] as String),
    );
    final message = messageManager.parse(response.jsonBody as Map<String, Object?>);

    messageManager.cache[message.id] = message;
    return message;
  }

  Future<Message> updateWebhookMessage(
    Snowflake webhookId,
    Snowflake messageId,
    MessageUpdateBuilder builder, {
    required String token,
    Snowflake? threadId,
  }) async {
    final route = HttpRoute()
      ..webhooks(id: webhookId.toString())
      ..add(HttpRoutePart(token))
      ..messages(id: messageId.toString());

    final queryParameters = {if (threadId != null) 'thread_id': threadId.toString()};
    final HttpRequest request;
    if (!identical(builder.attachments, sentinelList) && builder.attachments?.isNotEmpty == true) {
      final attachments = builder.attachments!;
      final payload = builder.build();

      final files = <MultipartFile>[];
      for (int i = 0; i < attachments.length; i++) {
        files.add(MultipartFile.fromBytes(
          'files[$i]',
          attachments[i].data,
          filename: attachments[i].fileName,
        ));

        ((payload['attachments'] as List)[i] as Map)['id'] = i.toString();
      }

      request = MultipartRequest(
        route,
        method: 'PATCH',
        jsonPayload: jsonEncode(payload),
        files: files,
        queryParameters: queryParameters,
        authenticated: false,
      );
    } else {
      request = BasicRequest(
        route,
        method: 'PATCH',
        body: jsonEncode(builder.build()),
        queryParameters: queryParameters,
        authenticated: false,
      );
    }

    final response = await client.httpHandler.executeSafe(request);
    final messageManager = MessageManager(
      client.options.messageCacheConfig,
      client,
      channelId: Snowflake.parse((response.jsonBody as Map<String, Object?>)['channel_id'] as String),
    );
    final message = messageManager.parse(response.jsonBody as Map<String, Object?>);

    messageManager.cache[message.id] = message;
    return message;
  }

  Future<void> deleteWebhookMessage(Snowflake webhookId, Snowflake messageId, {required String token, Snowflake? threadId}) async {
    final route = HttpRoute()
      ..webhooks(id: webhookId.toString())
      ..add(HttpRoutePart(token))
      ..messages(id: messageId.toString());
    final request = BasicRequest(
      route,
      method: 'DELETE',
      queryParameters: {if (threadId != null) 'thread_id': threadId.toString()},
      authenticated: false,
    );

    await client.httpHandler.executeSafe(request);
    // TODO: Can we delete the message from the cache?
  }
}
