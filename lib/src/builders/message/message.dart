import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/allowed_mentions.dart';
import 'package:nyxx/src/builders/message/attachment.dart';
import 'package:nyxx/src/builders/message/component.dart';
import 'package:nyxx/src/builders/message/embed.dart';
import 'package:nyxx/src/builders/message/poll.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/message/reference.dart';
import 'package:nyxx/src/models/snowflake.dart';

// TODO(abitofevrything): Remove replyId and requireReplyToExist properties.
class MessageBuilder extends CreateBuilder<Message> {
  String? content;

  dynamic /* int | String */ nonce;

  bool? tts;

  List<EmbedBuilder>? embeds;

  AllowedMentions? allowedMentions;

  MessageReferenceBuilder? referencedMessage;

  List<ActionRowBuilder>? components;

  List<Snowflake>? stickerIds;

  List<AttachmentBuilder>? attachments;

  bool? suppressEmbeds;

  bool? suppressNotifications;

  /// If true and nonce is present, it will be checked for uniqueness in the past few minutes. If another message was created by the same author with the same nonce,
  /// that message will be returned and no new message will be created.
  bool? enforceNonce;

  PollBuilder? poll;

  MessageBuilder({
    this.content,
    this.nonce,
    this.tts,
    this.embeds,
    this.allowedMentions,
    this.referencedMessage,
    @Deprecated('Use referencedMessage instead') Snowflake? replyId,
    @Deprecated('Use referencedMessage instead') bool? requireReplyToExist,
    this.components,
    this.stickerIds,
    this.attachments,
    this.suppressEmbeds,
    this.suppressNotifications,
    this.enforceNonce,
    this.poll,
  }) {
    if (replyId != null) {
      assert(referencedMessage == null, 'Cannot set replyId if referencedMessage is non-null');
      referencedMessage = MessageReferenceBuilder(
        type: MessageReferenceType.defaultType,
        messageId: replyId,
        failIfInexistent: requireReplyToExist,
      );
    }
  }

  @Deprecated('Use referencedMessage instead')
  Snowflake? get replyId => referencedMessage?.messageId;

  @Deprecated('Use referencedMessage instead')
  set replyId(Snowflake? replyId) {
    if (replyId == null) {
      referencedMessage = null;
    } else {
      referencedMessage = MessageReferenceBuilder(
        type: MessageReferenceType.defaultType,
        messageId: replyId,
      );
    }
  }

  @Deprecated('Use referencedMessage instead')
  bool? get requireReplyToExist => referencedMessage?.failIfInexistent;

  @Deprecated('Use referencedMessage instead')
  set requireReplyToExist(bool? requireReplyToExist) {
    if (referencedMessage != null) {
      referencedMessage!.failIfInexistent = requireReplyToExist;
    }
  }

  @override
  Map<String, Object?> build() => {
        if (content != null) 'content': content,
        if (nonce != null) 'nonce': nonce,
        if (tts != null) 'tts': tts,
        if (embeds != null) 'embeds': embeds!.map((e) => e.build()).toList(),
        if (allowedMentions != null) 'allowed_mentions': allowedMentions!.build(),
        if (referencedMessage != null) 'message_reference': referencedMessage!.build(),
        if (components != null) 'components': components!.map((e) => e.build()).toList(),
        if (stickerIds != null) 'sticker_ids': stickerIds!.map((e) => e.toString()).toList(),
        if (attachments != null) 'attachments': attachments!.map((e) => e.build()).toList(),
        if (suppressEmbeds != null || suppressNotifications != null)
          'flags':
              (suppressEmbeds == true ? MessageFlags.suppressEmbeds.value : 0) | (suppressNotifications == true ? MessageFlags.suppressNotifications.value : 0),
        if (enforceNonce != null) 'enforce_nonce': enforceNonce,
        if (poll != null) 'poll': poll!.build(),
      };
}

class MessageUpdateBuilder extends UpdateBuilder<Message> {
  String? content;

  List<EmbedBuilder>? embeds;

  bool? suppressEmbeds;

  AllowedMentions? allowedMentions;

  List<ActionRowBuilder>? components;

  List<AttachmentBuilder>? attachments;

  /// Can only be used when editing a deferred interaction.
  PollBuilder? poll;

  MessageUpdateBuilder({
    this.content = sentinelString,
    this.embeds = sentinelList,
    this.suppressEmbeds,
    this.allowedMentions,
    this.components,
    this.attachments = sentinelList,
    this.poll,
  });

  @override
  Map<String, Object?> build() => {
        if (!identical(content, sentinelString)) 'content': content,
        if (!identical(embeds, sentinelList)) 'embeds': embeds!.map((e) => e.build()).toList(),
        if (allowedMentions != null) 'allowed_mentions': allowedMentions!.build(),
        if (components != null) 'components': components!.map((e) => e.build()).toList(),
        if (!identical(attachments, sentinelList)) 'attachments': attachments!.map((e) => e.build()).toList(),
        if (suppressEmbeds != null) 'flags': (suppressEmbeds == true ? MessageFlags.suppressEmbeds.value : 0),
        if (poll != null) 'poll': poll!.build(),
      };
}

class MessageReferenceBuilder extends CreateBuilder<MessageReference> {
  MessageReferenceType type;

  Snowflake messageId;

  Snowflake? channelId;

  Snowflake? guildId;

  bool? failIfInexistent;

  MessageReferenceBuilder({
    required this.type,
    required this.messageId,
    this.channelId,
    this.guildId,
    this.failIfInexistent,
  });

  MessageReferenceBuilder.reply({
    required this.messageId,
    this.channelId,
    this.guildId,
    this.failIfInexistent,
  }) : type = MessageReferenceType.defaultType;

  MessageReferenceBuilder.forward({
    required this.messageId,
    required Snowflake this.channelId,
    this.guildId,
    this.failIfInexistent,
  }) : type = MessageReferenceType.forward;

  @override
  Map<String, Object?> build() => {
        'type': type.value,
        'message_id': messageId.toString(),
        if (channelId != null) 'channel_id': channelId!.toString(),
        if (guildId != null) 'guild_id': guildId!.toString(),
        if (failIfInexistent != null) 'fail_if_not_exists': failIfInexistent,
      };
}
