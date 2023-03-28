import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/message/activity.dart';
import 'package:nyxx/src/models/message/attachment.dart';
import 'package:nyxx/src/models/message/channel_mention.dart';
import 'package:nyxx/src/models/message/embed.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/message/reaction.dart';
import 'package:nyxx/src/models/message/reference.dart';
import 'package:nyxx/src/models/message/role_subscription_data.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class MessageManager extends Manager<Message> {
  final Snowflake channelId;

  MessageManager(super.config, super.client, {required this.channelId});

  @override
  PartialMessage operator [](Snowflake id) => PartialMessage(id: id, manager: this);

  @override
  Message parse(Map<String, Object?> raw) {
    return Message(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      // TODO: Could be a webhook
      author: client.users.parse(raw['author'] as Map<String, Object?>),
      content: raw['content'] as String,
      timestamp: DateTime.parse(raw['timestamp'] as String),
      editedTimestamp: maybeParse(raw['edited_timestamp'], DateTime.parse),
      isTts: raw['tts'] as bool,
      mentionsEveryone: raw['mention_everyone'] as bool,
      mentions: parseMany(raw['mentions'] as List, client.users.parse),
      channelMentions: maybeParseMany(raw['mention_channels'], parseChannelMention) ?? [],
      attachments: parseMany(raw['attachments'] as List, parseAttachment),
      embeds: parseMany(raw['embeds'] as List, parseEmbed),
      reactions: maybeParseMany(raw['reactions'], parseReaction) ?? [],
      nonce: raw['nonce'] /* as int | String */,
      pinned: raw['pinned'] as bool,
      webhookId: maybeParse(raw['webhook_id'], Snowflake.parse),
      type: MessageType.parse(raw['type'] as int),
      activity: maybeParse(raw['activity'], parseMessageActivity),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      reference: maybeParse(raw['message_reference'], parseMessageReference),
      flags: MessageFlags(raw['flags'] as int? ?? 0),
      referencedMessage: maybeParse(raw['referenced_message'], parse),
      thread: maybeParse(raw['thread'], client.channels.parse) as Thread?,
      position: raw['position'] as int?,
      roleSubscriptionData: maybeParse(raw['role_subscription_data'], parseRoleSubscriptionData),
    );
  }

  ChannelMention parseChannelMention(Map<String, Object?> raw) {
    return ChannelMention(
      id: Snowflake.parse(raw['id'] as String),
      manager: client.channels,
      guildId: Snowflake.parse(raw['guild_id'] as String),
      type: ChannelType.parse(raw['type'] as int),
      name: raw['name'] as String,
    );
  }

  Attachment parseAttachment(Map<String, Object?> raw) {
    return Attachment(
      id: Snowflake.parse(raw['id'] as String),
      fileName: raw['filename'] as String,
      description: raw['description'] as String?,
      contentType: raw['content_type'] as String?,
      size: raw['size'] as int,
      url: Uri.parse(raw['url'] as String),
      proxiedUrl: Uri.parse(raw['proxy_url'] as String),
      height: raw['height'] as int?,
      width: raw['width'] as int?,
      ephemeral: raw['ephemeral'] as bool? ?? false,
    );
  }

  Embed parseEmbed(Map<String, Object?> raw) {
    return Embed(
      title: raw['title'] as String?,
      // TODO This field is nullable
      type: EmbedType.parse(raw['type'] as String),
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
      me: raw['me'] as bool,
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
      messageId: maybeParse(raw['message_id'], Snowflake.parse),
      channelId: Snowflake.parse(raw['channel_id'] as String),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
    );
  }

  RoleSubscriptionData parseRoleSubscriptionData(Map<String, Object?> raw) {
    return RoleSubscriptionData(
      listingId: Snowflake.parse(raw['role_subscription_listing_id'] as String),
      tierName: raw['tier_name'] as String,
      totalMonthsSubscribed: raw['total_months_subscribed'] as int,
      isRenewal: raw['is_renewal'] as bool,
    );
  }

  @override
  Future<Message> create(CreateBuilder<Message> builder) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Message> fetch(Snowflake id) {
    // TODO: implement fetch
    throw UnimplementedError();
  }

  @override
  Future<Message> update(Snowflake id, UpdateBuilder<Message> builder) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<void> delete(Snowflake id) {
    // TODO: implement delete
    throw UnimplementedError();
  }
}
