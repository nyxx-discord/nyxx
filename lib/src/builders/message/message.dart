import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/allowed_mentions.dart';
import 'package:nyxx/src/builders/message/attachment.dart';
import 'package:nyxx/src/builders/message/component.dart';
import 'package:nyxx/src/builders/message/embed.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';

class MessageBuilder extends CreateBuilder<Message> {
  final String? content;

  final dynamic /* int | String */ nonce;

  final bool? tts;

  final List<EmbedBuilder>? embeds;

  final AllowedMentions? allowedMentions;

  final Snowflake? replyId;

  final bool? requireReplyToExist;

  final List<ActionRowBuilder>? components;

  final List<Snowflake>? stickerIds;

  final List<AttachmentBuilder>? attachments;

  final bool? suppressEmbeds;

  final bool? suppressNotifications;

  MessageBuilder({
    this.content,
    this.nonce,
    this.tts,
    this.embeds,
    this.allowedMentions,
    this.replyId,
    this.requireReplyToExist,
    this.components,
    this.stickerIds,
    this.attachments,
    this.suppressEmbeds,
    this.suppressNotifications,
  });

  @override
  Map<String, Object?> build() => {
        if (content != null) 'content': content,
        if (nonce != null) 'nonce': nonce,
        if (tts != null) 'tts': tts,
        if (embeds != null) 'embeds': embeds!.map((e) => e.build()).toList(),
        if (allowedMentions != null) 'allowed_mentions': allowedMentions!.build(),
        if (replyId != null)
          'message_reference': {
            'message_id': replyId.toString(),
            if (requireReplyToExist != null) 'fail_if_not_exists': requireReplyToExist,
          },
        if (components != null) 'components': components!.map((e) => e.build()).toList(),
        if (stickerIds != null) 'sticker_ids': stickerIds!.map((e) => e.toString()).toList(),
        if (attachments != null) 'attachments': attachments!.map((e) => e.build()).toList(),
        if (suppressEmbeds != null || suppressNotifications != null)
          'flags':
              (suppressEmbeds == true ? MessageFlags.suppressEmbeds.value : 0) | (suppressNotifications == true ? MessageFlags.suppressNotifications.value : 0),
      };
}

class MessageUpdateBuilder extends UpdateBuilder<Message> {
  final String? content;

  final List<EmbedBuilder>? embeds;

  final bool? suppressEmbeds;

  final AllowedMentions? allowedMentions;

  final List<ActionRowBuilder>? components;

  final List<AttachmentBuilder>? attachments;

  MessageUpdateBuilder({
    this.content = sentinelString,
    this.embeds = sentinelList,
    this.suppressEmbeds,
    this.allowedMentions,
    this.components,
    this.attachments = sentinelList,
  });

  @override
  Map<String, Object?> build() => {
        if (!identical(content, sentinelString)) 'content': content,
        if (!identical(embeds, sentinelList)) 'embeds': embeds!.map((e) => e.build()).toList(),
        if (allowedMentions != null) 'allowed_mentions': allowedMentions!.build(),
        if (components != null) 'components': components!.map((e) => e.build()).toList(),
        if (!identical(attachments, sentinelList)) 'attachments': attachments!.map((e) => e.build()).toList(),
        if (suppressEmbeds != null) 'flags': (suppressEmbeds == true ? MessageFlags.suppressEmbeds.value : 0),
      };
}
