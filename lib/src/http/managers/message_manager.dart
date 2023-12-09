import 'dart:convert';

import 'package:http/http.dart' show MultipartFile;
import 'package:nyxx/src/builders/emoji/reaction.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/message/activity.dart';
import 'package:nyxx/src/models/message/attachment.dart';
import 'package:nyxx/src/models/message/author.dart';
import 'package:nyxx/src/models/message/channel_mention.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:nyxx/src/models/message/embed.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/message/reaction.dart';
import 'package:nyxx/src/models/message/reference.dart';
import 'package:nyxx/src/models/message/role_subscription_data.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Message]s in a [TextChannel].
class MessageManager extends Manager<Message> {
  /// The ID of the [TextChannel] this manager is attached to.
  final Snowflake channelId;

  /// Create a new [MessageManager].
  MessageManager(super.config, super.client, {required this.channelId}) : super(identifier: '$channelId.messages');

  @override
  PartialMessage operator [](Snowflake id) => PartialMessage(id: id, manager: this);

  @override
  Message parse(Map<String, Object?> raw, {Snowflake? guildId}) {
    if (client.channels.cache[channelId] case GuildChannel(guildId: final guildIdFromChannel)) {
      guildId ??= guildIdFromChannel;
    }

    final webhookId = maybeParse(raw['webhook_id'], Snowflake.parse);

    return Message(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      author: (webhookId == null
          ? client.users.parse(raw['author'] as Map<String, Object?>)
          : client.webhooks.parseWebhookAuthor(raw['author'] as Map<String, Object?>)) as MessageAuthor,
      content: raw['content'] as String,
      timestamp: DateTime.parse(raw['timestamp'] as String),
      editedTimestamp: maybeParse(raw['edited_timestamp'], DateTime.parse),
      isTts: raw['tts'] as bool,
      mentionsEveryone: raw['mention_everyone'] as bool,
      mentions: parseMany(raw['mentions'] as List, client.users.parse),
      roleMentionIds: parseMany(raw['mention_roles'] as List, Snowflake.parse),
      channelMentions: maybeParseMany(raw['mention_channels'], parseChannelMention) ?? [],
      attachments: parseMany(raw['attachments'] as List, parseAttachment),
      embeds: parseMany(raw['embeds'] as List, parseEmbed),
      reactions: maybeParseMany(raw['reactions'], parseReaction) ?? [],
      nonce: raw['nonce'] /* as int | String */,
      isPinned: raw['pinned'] as bool,
      webhookId: webhookId,
      type: MessageType.parse(raw['type'] as int),
      activity: maybeParse(raw['activity'], parseMessageActivity),
      application: maybeParse(
        raw['application'],
        (Map<String, Object?> raw) => PartialApplication(id: Snowflake.parse(raw['id']!), manager: client.applications),
      ),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      reference: maybeParse(raw['message_reference'], parseMessageReference),
      flags: MessageFlags(raw['flags'] as int? ?? 0),
      referencedMessage: maybeParse(raw['referenced_message'], parse),
      interaction: maybeParse(
        raw['interaction'],
        (Map<String, Object?> raw) => parseMessageInteraction(raw, guildId: guildId),
      ),
      thread: maybeParse(raw['thread'], client.channels.parse) as Thread?,
      components: maybeParseMany(raw['components'], parseMessageComponent),
      position: raw['position'] as int?,
      roleSubscriptionData: maybeParse(raw['role_subscription_data'], parseRoleSubscriptionData),
      stickers: parseMany(raw['sticker_items'] as List? ?? [], client.stickers.parseStickerItem),
      resolved: maybeParse(raw['resolved'], (Map<String, Object?> raw) => client.interactions.parseResolvedData(raw, guildId: guildId, channelId: channelId)),
    );
  }

  ChannelMention parseChannelMention(Map<String, Object?> raw) {
    return ChannelMention(
      id: Snowflake.parse(raw['id']!),
      manager: client.channels,
      guildId: Snowflake.parse(raw['guild_id']!),
      type: ChannelType.parse(raw['type'] as int),
      name: raw['name'] as String,
    );
  }

  Attachment parseAttachment(Map<String, Object?> raw) {
    return Attachment(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      fileName: raw['filename'] as String,
      description: raw['description'] as String?,
      contentType: raw['content_type'] as String?,
      size: raw['size'] as int,
      url: Uri.parse(raw['url'] as String),
      proxiedUrl: Uri.parse(raw['proxy_url'] as String),
      height: raw['height'] as int?,
      width: raw['width'] as int?,
      isEphemeral: raw['ephemeral'] as bool? ?? false,
      duration: maybeParse(raw['duration_secs'], (double value) => Duration(microseconds: (value * Duration.microsecondsPerSecond).floor())),
      waveform: maybeParse(raw['waveform'], base64.decode),
      flags: maybeParse(raw['flags'], AttachmentFlags.new),
    );
  }

  Embed parseEmbed(Map<String, Object?> raw) {
    return Embed(
      title: raw['title'] as String?,
      description: raw['description'] as String?,
      url: maybeParse(raw['url'], Uri.parse),
      timestamp: maybeParse(raw['timestamp'], DateTime.parse),
      color: maybeParse(raw['color'], DiscordColor.new),
      footer: maybeParse(raw['footer'], parseEmbedFooter),
      image: maybeParse(raw['image'], parseEmbedImage),
      thumbnail: maybeParse(raw['thumbnail'], parseEmbedThumbnail),
      video: maybeParse(raw['video'], parseEmbedVideo),
      provider: maybeParse(raw['provider'], parseEmbedProvider),
      author: maybeParse(raw['author'], parseEmbedAuthor),
      fields: maybeParseMany(raw['fields'], parseEmbedField),
    );
  }

  EmbedFooter parseEmbedFooter(Map<String, Object?> raw) {
    return EmbedFooter(
      text: raw['text'] as String,
      iconUrl: maybeParse(raw['icon_url'], Uri.parse),
      proxiedIconUrl: maybeParse(raw['proxy_icon_url'], Uri.parse),
    );
  }

  EmbedImage parseEmbedImage(Map<String, Object?> raw) {
    return EmbedImage(
      url: Uri.parse(raw['url'] as String),
      proxiedUrl: maybeParse(raw['proxy_url'], Uri.parse),
      height: raw['height'] as int?,
      width: raw['width'] as int?,
    );
  }

  EmbedThumbnail parseEmbedThumbnail(Map<String, Object?> raw) {
    return EmbedThumbnail(
      url: Uri.parse(raw['url'] as String),
      proxiedUrl: maybeParse(raw['proxy_url'], Uri.parse),
      height: raw['height'] as int?,
      width: raw['width'] as int?,
    );
  }

  EmbedVideo parseEmbedVideo(Map<String, Object?> raw) {
    return EmbedVideo(
      url: Uri.parse(raw['url'] as String),
      proxiedUrl: maybeParse(raw['proxy_url'], Uri.parse),
      height: raw['height'] as int?,
      width: raw['width'] as int?,
    );
  }

  EmbedProvider parseEmbedProvider(Map<String, Object?> raw) {
    return EmbedProvider(
      name: raw['name'] as String?,
      url: maybeParse(raw['url'], Uri.parse),
    );
  }

  EmbedAuthor parseEmbedAuthor(Map<String, Object?> raw) {
    return EmbedAuthor(
      name: raw['name'] as String,
      url: maybeParse(raw['url'], Uri.parse),
      iconUrl: maybeParse(raw['icon_url'], Uri.parse),
      proxyIconUrl: maybeParse(raw['proxy_icon_url'], Uri.parse),
    );
  }

  EmbedField parseEmbedField(Map<String, Object?> raw) {
    return EmbedField(
      name: raw['name'] as String,
      value: raw['value'] as String,
      inline: raw['inline'] as bool? ?? false,
    );
  }

  Reaction parseReaction(Map<String, Object?> raw) {
    return Reaction(
      count: raw['count'] as int,
      countDetails: parseReactionCountDetails(raw['count_details'] as Map<String, Object?>),
      me: raw['me'] as bool,
      meBurst: raw['me_burst'] as bool,
      emoji: client.guilds[Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>),
      burstColors: parseMany(raw['burst_colors'] as List, DiscordColor.parseHexString),
    );
  }

  ReactionCountDetails parseReactionCountDetails(Map<String, Object?> raw) {
    return ReactionCountDetails(
      burst: raw['burst'] as int,
      normal: raw['normal'] as int,
    );
  }

  MessageActivity parseMessageActivity(Map<String, Object?> raw) {
    return MessageActivity(
      type: MessageActivityType.parse(raw['type'] as int),
      partyId: raw['party_id'] as String?,
    );
  }

  MessageReference parseMessageReference(Map<String, Object?> raw) {
    return MessageReference(
      manager: this,
      messageId: maybeParse(raw['message_id'], Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  RoleSubscriptionData parseRoleSubscriptionData(Map<String, Object?> raw) {
    return RoleSubscriptionData(
      listingId: Snowflake.parse(raw['role_subscription_listing_id']!),
      tierName: raw['tier_name'] as String,
      totalMonthsSubscribed: raw['total_months_subscribed'] as int,
      isRenewal: raw['is_renewal'] as bool,
    );
  }

  MessageComponent parseMessageComponent(Map<String, Object?> raw) {
    final type = MessageComponentType.parse(raw['type'] as int);

    return switch (type) {
      MessageComponentType.actionRow => ActionRowComponent(
          components: parseMany(raw['components'] as List, parseMessageComponent),
        ),
      MessageComponentType.button => ButtonComponent(
          style: ButtonStyle.parse(raw['style'] as int),
          label: raw['label'] as String?,
          emoji: maybeParse(raw['emoji'], client.guilds[Snowflake.zero].emojis.parse),
          customId: raw['custom_id'] as String?,
          url: maybeParse(raw['url'], Uri.parse),
          isDisabled: raw['disabled'] as bool?,
        ),
      MessageComponentType.textInput => TextInputComponent(
          customId: raw['custom_id'] as String,
          style: maybeParse(raw['style'], TextInputStyle.parse),
          label: raw['label'] as String?,
          minLength: raw['min_length'] as int?,
          maxLength: raw['max_length'] as int?,
          isRequired: raw['required'] as bool?,
          value: raw['value'] as String?,
          placeholder: raw['placeholder'] as String?,
        ),
      MessageComponentType.stringSelect ||
      MessageComponentType.userSelect ||
      MessageComponentType.roleSelect ||
      MessageComponentType.mentionableSelect ||
      MessageComponentType.channelSelect =>
        SelectMenuComponent(
          type: type,
          customId: raw['custom_id'] as String,
          options: maybeParseMany(raw['options'], parseSelectMenuOption),
          channelTypes: maybeParseMany(raw['channel_types'], ChannelType.parse),
          placeholder: raw['placeholder'] as String?,
          defaultValues: maybeParseMany(raw['default_values'], parseSelectMenuDefaultValue),
          minValues: raw['min_values'] as int?,
          maxValues: raw['max_values'] as int?,
          isDisabled: raw['disabled'] as bool?,
        ),
    };
  }

  SelectMenuOption parseSelectMenuOption(Map<String, Object?> raw) {
    return SelectMenuOption(
      label: raw['label'] as String,
      value: raw['value'] as String,
      description: raw['description'] as String?,
      emoji: maybeParse(raw['emoji'], client.guilds[Snowflake.zero].emojis.parse),
      isDefault: raw['default'] as bool?,
    );
  }

  SelectMenuDefaultValue parseSelectMenuDefaultValue(Map<String, Object?> raw) {
    return SelectMenuDefaultValue(
      id: Snowflake.parse(raw['id']!),
      type: SelectMenuDefaultValueType.parse(raw['type'] as String),
    );
  }

  MessageInteraction parseMessageInteraction(Map<String, Object?> raw, {Snowflake? guildId}) {
    final user = client.users.parse(raw['user'] as Map<String, Object?>);

    return MessageInteraction(
      id: Snowflake.parse(raw['id']!),
      type: InteractionType.parse(raw['type'] as int),
      name: raw['name'] as String,
      user: user,
      member: maybeParse(
        raw['member'],
        (Map<String, Object?> raw) => client.guilds[guildId ?? Snowflake.zero].members[user.id],
      ),
    );
  }

  @override
  Future<Message> create(MessageBuilder builder) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages();

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
      );
    } else {
      request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));
    }

    final response = await client.httpHandler.executeSafe(request);
    final message = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(message);
    return message;
  }

  @override
  Future<Message> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final message = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(message);
    return message;
  }

  @override
  Future<Message> update(Snowflake id, MessageUpdateBuilder builder) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString());

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
      );
    } else {
      request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));
    }

    final response = await client.httpHandler.executeSafe(request);
    final message = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(message);
    return message;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);

    cache.remove(id);
  }

  /// Fetch multiple messages in this channel.
  Future<List<Message>> fetchMany({Snowflake? around, Snowflake? before, Snowflake? after, int? limit}) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages();
    final request = BasicRequest(
      route,
      queryParameters: {
        if (around != null) 'around': around.toString(),
        if (before != null) 'before': before.toString(),
        if (after != null) 'after': after.toString(),
        if (limit != null) 'limit': limit.toString(),
      },
    );

    final response = await client.httpHandler.executeSafe(request);
    final messages = parseMany(response.jsonBody as List, parse);

    messages.forEach(client.updateCacheWith);
    return messages;
  }

  /// Crosspost a message to all channels following the channel it was sent in.
  Future<Message> crosspost(Snowflake id) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..crosspost();
    final request = BasicRequest(route, method: 'POST');

    final response = await client.httpHandler.executeSafe(request);
    final message = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(message);
    return message;
  }

  /// Bulk delete many messages at once
  ///
  /// This will throw an error if any of [ids] is not a valid message ID or if any of the messages are from before [Snowflake.bulkDeleteLimit].
  Future<void> bulkDelete(Iterable<Snowflake> ids) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages()
      ..bulkDelete();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(ids.map((e) => e.toString()).toList()));

    await client.httpHandler.executeSafe(request);
  }

  /// Get the pinned messages in the channel.
  Future<List<Message>> getPins() async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..pins();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final messages = parseMany(response.jsonBody as List, parse);

    messages.forEach(client.updateCacheWith);
    return messages;
  }

  /// Pin a message in the channel.
  Future<void> pin(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..pins(id: id.toString());
    final request = BasicRequest(route, method: 'PUT', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }

  /// Unpin a message in the channel.
  Future<void> unpin(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..pins(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }

  /// Adds a reaction to a message.
  Future<void> addReaction(Snowflake id, ReactionBuilder emoji) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..reactions(emoji: emoji.build(), userId: '@me');

    final request = BasicRequest(route, method: 'PUT');

    await client.httpHandler.executeSafe(request);
  }

  /// Deletes our own reaction from a message.
  Future<void> deleteOwnReaction(Snowflake id, ReactionBuilder emoji) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..reactions(emoji: emoji.build(), userId: '@me');

    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Deletes all reactions on a message.
  Future<void> deleteAllReactions(Snowflake id) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..reactions();
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Deletes all reactions for a given emoji on a message.
  Future<void> deleteReactionForUser(Snowflake id, Snowflake userId, ReactionBuilder emoji) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..reactions(emoji: emoji.build(), userId: userId.toString());

    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Deletes all reactions for a given emoji on a message.
  Future<void> deleteReaction(Snowflake id, ReactionBuilder emoji) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..reactions(emoji: emoji.build());

    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Get a list of users that reacted with a given emoji on a message.
  Future<List<User>> fetchReactions(Snowflake id, ReactionBuilder emoji) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..messages(id: id.toString())
      ..reactions(emoji: emoji.build());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final users = parseMany(response.jsonBody as List, client.users.parse);

    users.forEach(client.updateCacheWith);
    return users;
  }

  // TODO once oauth2 is implemented: Group DM control endpoints
}
