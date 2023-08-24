import 'dart:convert';

import 'package:http/http.dart' hide MultipartRequest;
import 'package:nyxx/src/builders/interaction_response.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A [Manager] for [Interaction]s.
class InteractionManager {
  /// The client for this [InteractionManager].
  final NyxxRest client;

  /// The ID of the application for this [InteractionManager].
  final Snowflake applicationId;

  /// Create a new [InteractionManager].
  InteractionManager(this.client, {required this.applicationId});

  Interaction<dynamic> parse(Map<String, Object?> raw) {
    final type = InteractionType.parse(raw['type'] as int);
    final guildId = maybeParse(raw['guild_id'], Snowflake.parse);
    final channelId = maybeParse(raw['channel_id'], Snowflake.parse);
    final id = Snowflake.parse(raw['id']!);
    final applicationId = Snowflake.parse(raw['application_id']!);
    final channel = maybeParse(raw['channel'], (Map<String, Object?> raw) => client.channels[Snowflake.parse(raw['id']!)]);
    final member = maybeParse(raw['member'], client.guilds[guildId ?? Snowflake.zero].members.parse);
    final user = maybeParse(raw['user'], client.users.parse);
    final token = raw['token'] as String;
    final version = raw['version'] as int;
    final message = maybeParse(raw['message'], (client.channels[channelId ?? Snowflake.zero] as PartialTextChannel).messages.parse);
    final appPermissions = maybeParse(raw['app_permissions'], (String raw) => Permissions(int.parse(raw)));
    final locale = maybeParse(raw['locale'], Locale.parse);
    final guildLocale = maybeParse(raw['guild_locale'], Locale.parse);

    return switch (type) {
      InteractionType.ping => PingInteraction(
          manager: this,
          id: id,
          applicationId: applicationId,
          type: type,
          guildId: guildId,
          channel: channel,
          channelId: channelId,
          member: member,
          user: user,
          token: token,
          version: version,
          message: message,
          appPermissions: appPermissions,
          locale: locale,
          guildLocale: guildLocale,
        ),
      InteractionType.applicationCommand => ApplicationCommandInteraction(
          manager: this,
          id: id,
          applicationId: applicationId,
          type: type,
          data: parseApplicationCommandInteractionData(raw['data'] as Map<String, Object?>, guildId: guildId, channelId: channelId),
          guildId: guildId,
          channel: channel,
          channelId: channelId,
          member: member,
          user: user,
          token: token,
          version: version,
          message: message,
          appPermissions: appPermissions,
          locale: locale,
          guildLocale: guildLocale,
        ),
      InteractionType.messageComponent => MessageComponentInteraction(
          manager: this,
          id: id,
          applicationId: applicationId,
          type: type,
          data: parseMessageComponentInteractionData(raw['data'] as Map<String, Object?>),
          guildId: guildId,
          channel: channel,
          channelId: channelId,
          member: member,
          user: user,
          token: token,
          version: version,
          message: message,
          appPermissions: appPermissions,
          locale: locale,
          guildLocale: guildLocale,
        ),
      InteractionType.modalSubmit => ModalSubmitInteraction(
          manager: this,
          id: id,
          applicationId: applicationId,
          type: type,
          data: parseModalSubmitInteractionData(raw['data'] as Map<String, Object?>),
          guildId: guildId,
          channel: channel,
          channelId: channelId,
          member: member,
          user: user,
          token: token,
          version: version,
          message: message,
          appPermissions: appPermissions,
          locale: locale,
          guildLocale: guildLocale,
        ),
      InteractionType.applicationCommandAutocomplete => ApplicationCommandAutocompleteInteraction(
          manager: this,
          id: id,
          applicationId: applicationId,
          type: type,
          data: parseApplicationCommandInteractionData(raw['data'] as Map<String, Object?>, guildId: guildId, channelId: channelId),
          guildId: guildId,
          channel: channel,
          channelId: channelId,
          member: member,
          user: user,
          token: token,
          version: version,
          message: message,
          appPermissions: appPermissions,
          locale: locale,
          guildLocale: guildLocale,
        ),
    } as Interaction;
  }

  ApplicationCommandInteractionData parseApplicationCommandInteractionData(Map<String, Object?> raw, {Snowflake? guildId, Snowflake? channelId}) {
    return ApplicationCommandInteractionData(
      id: Snowflake.parse(raw['id']!),
      name: raw['name'] as String,
      type: ApplicationCommandType.parse(raw['type'] as int),
      resolved: maybeParse(raw['resolved'], (Map<String, Object?> raw) => parseResolvedData(raw, guildId: guildId, channelId: channelId)),
      options: maybeParseMany(raw['options'], parseInteractionOption),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      targetId: maybeParse(raw['target_id'], Snowflake.parse),
    );
  }

  ResolvedData parseResolvedData(Map<String, Object?> raw, {Snowflake? guildId, Snowflake? channelId}) {
    return ResolvedData(
      users: maybeParse(
        raw['users'],
        (Map<String, Object?> raw) => raw.map((key, value) => MapEntry(Snowflake.parse(key), client.users.parse(value as Map<String, Object?>))),
      ),
      members: maybeParse(
        raw['members'],
        (Map<String, Object?> raw) =>
            raw.map((key, value) => MapEntry(Snowflake.parse(key), client.guilds[guildId ?? Snowflake.zero].members.parse(value as Map<String, Object?>))),
      ),
      roles: maybeParse(
        raw['roles'],
        (Map<String, Object?> raw) =>
            raw.map((key, value) => MapEntry(Snowflake.parse(key), client.guilds[guildId ?? Snowflake.zero].roles.parse(value as Map<String, Object?>))),
      ),
      channels: maybeParse(
        raw['channels'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(
            Snowflake.parse(key),
            PartialChannel(id: Snowflake.parse((value as Map<String, Object?>)['id']!), manager: client.channels),
          ),
        ),
      ),
      messages: maybeParse(
        raw['messages'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(
            Snowflake.parse(key),
            PartialMessage(
                id: Snowflake.parse((value as Map<String, Object?>)['id']!),
                manager: (client.channels[channelId ?? Snowflake.zero] as PartialTextChannel).messages),
          ),
        ),
      ),
      attachments: maybeParse(
        raw['attachments'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(
            Snowflake.parse(key),
            (client.channels[channelId ?? Snowflake.zero] as PartialTextChannel).messages.parseAttachment(value as Map<String, Object?>),
          ),
        ),
      ),
    );
  }

  InteractionOption parseInteractionOption(Map<String, Object?> raw) {
    return InteractionOption(
      name: raw['name'] as String,
      type: CommandOptionType.parse(raw['type'] as int),
      value: raw['value'],
      options: maybeParseMany(raw['options'], parseInteractionOption),
      isFocused: raw['focused'] as bool?,
    );
  }

  MessageComponentInteractionData parseMessageComponentInteractionData(Map<String, Object?> raw) {
    return MessageComponentInteractionData(
      customId: raw['custom_id'] as String,
      type: MessageComponentType.parse(raw['component_type'] as int),
      values: maybeParseMany(raw['values']),
    );
  }

  ModalSubmitInteractionData parseModalSubmitInteractionData(Map<String, Object?> raw) {
    return ModalSubmitInteractionData(
      customId: raw['custom_id'] as String,
      components: parseMany(raw['components'] as List, (client.channels[Snowflake.zero] as PartialTextChannel).messages.parseMessageComponent),
    );
  }

  /// Create a response to an interaction.
  Future<void> createResponse(Snowflake id, String token, InteractionResponseBuilder builder) async {
    final route = HttpRoute()
      ..interactions(id: id.toString(), token: token)
      ..callback();

    final HttpRequest request;
    if (builder.data case MessageBuilder(:final attachments?) || MessageUpdateBuilder(:final attachments?)
        when !identical(attachments, sentinelList) && attachments.isNotEmpty) {
      final payload = builder.build();

      final files = <MultipartFile>[];
      for (int i = 0; i < attachments.length; i++) {
        files.add(MultipartFile.fromBytes(
          'files[$i]',
          attachments[i].data,
          filename: attachments[i].fileName,
        ));

        (((payload['data'] as Map<String, Object?>)['attachments'] as List)[i] as Map<String, Object?>)['id'] = i.toString();
      }

      request = MultipartRequest(
        route,
        method: 'POST',
        jsonPayload: jsonEncode(payload),
        files: files,
        applyGlobalRateLimit: false,
      );
    } else {
      request = BasicRequest(
        route,
        method: 'POST',
        body: jsonEncode(builder.build()),
        applyGlobalRateLimit: false,
      );
    }

    await client.httpHandler.executeSafe(request);
  }

  /// Fetch an interaction's original response.
  Future<Message> fetchOriginalResponse(String token) => _fetchResponse(token, '@original');

  /// Update an interaction's original response.
  Future<Message> updateOriginalResponse(String token, MessageUpdateBuilder builder) => _updateResponse(token, '@original', builder);

  /// Delete an interaction's original response.
  Future<void> deleteOriginalResponse(String token) => _deleteResponse(token, '@original');

  /// Create a followup to an interaction.
  Future<Message> createFollowup(String token, MessageBuilder builder, {bool? isEphemeral}) async {
    final route = HttpRoute()
      ..webhooks(id: applicationId.toString())
      ..add(HttpRoutePart(token));

    final builtMessagePayload = builder.build();
    if (isEphemeral != null) {
      builtMessagePayload['flags'] = (builtMessagePayload['flags'] as int? ?? 0) | (isEphemeral ? MessageFlags.ephemeral.value : 0);
    }

    final HttpRequest request;
    if (!identical(builder.attachments, sentinelList) && builder.attachments?.isNotEmpty == true) {
      final attachments = builder.attachments!;

      final files = <MultipartFile>[];
      for (int i = 0; i < attachments.length; i++) {
        files.add(MultipartFile.fromBytes(
          'files[$i]',
          attachments[i].data,
          filename: attachments[i].fileName,
        ));

        ((builtMessagePayload['attachments'] as List)[i] as Map)['id'] = i.toString();
      }

      request = MultipartRequest(
        route,
        method: 'POST',
        jsonPayload: jsonEncode(builtMessagePayload),
        files: files,
        applyGlobalRateLimit: false,
      );
    } else {
      request = BasicRequest(
        route,
        method: 'POST',
        body: jsonEncode(builtMessagePayload),
        applyGlobalRateLimit: false,
      );
    }

    final response = await client.httpHandler.executeSafe(request);

    final channelId = Snowflake.parse((response.jsonBody as Map<String, Object?>)['channel_id']!);
    return (client.channels[channelId] as PartialTextChannel).messages.parse(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch a followup to an interaction.
  Future<Message> fetchFollowup(String token, Snowflake messageId) => _fetchResponse(token, messageId.toString());

  /// Update a followup to an interaction.
  Future<Message> updateFollowup(String token, Snowflake messageId, MessageUpdateBuilder builder) => _updateResponse(token, messageId.toString(), builder);

  /// Delete a followup to an interaction.
  Future<void> deleteFollowup(String token, Snowflake messageId) => _deleteResponse(token, messageId.toString());

  Future<Message> _fetchResponse(String token, String messageId) async {
    final route = HttpRoute()
      ..webhooks(id: applicationId.toString(), token: token)
      ..messages(id: messageId);
    final request = BasicRequest(route, applyGlobalRateLimit: false);

    final response = await client.httpHandler.executeSafe(request);

    final channelId = Snowflake.parse((response.jsonBody as Map<String, Object?>)['channel_id']!);
    return (client.channels[channelId] as PartialTextChannel).messages.parse(response.jsonBody as Map<String, Object?>);
  }

  Future<Message> _updateResponse(String token, String messageId, MessageUpdateBuilder builder) async {
    final route = HttpRoute()
      ..webhooks(id: applicationId.toString(), token: token)
      ..messages(id: messageId.toString());

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
        applyGlobalRateLimit: false,
      );
    } else {
      request = BasicRequest(
        route,
        method: 'PATCH',
        body: jsonEncode(builder.build()),
        applyGlobalRateLimit: false,
      );
    }

    final response = await client.httpHandler.executeSafe(request);
    final channelId = Snowflake.parse((response.jsonBody as Map<String, Object?>)['channel_id']!);
    return (client.channels[channelId] as PartialTextChannel).messages.parse(response.jsonBody as Map<String, Object?>);
  }

  Future<void> _deleteResponse(String token, String messageId) async {
    final route = HttpRoute()
      ..webhooks(id: applicationId.toString(), token: token)
      ..messages(id: messageId);
    final request = BasicRequest(route, method: 'DELETE', applyGlobalRateLimit: false);

    await client.httpHandler.executeSafe(request);
  }
}
