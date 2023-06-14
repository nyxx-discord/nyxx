import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/allowed_mentions.dart';
import 'package:nyxx/src/builders/message/attachment.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/message/embed.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';

class MessageBuilder extends CreateBuilder<Message> {
  final String? content;

  final dynamic /* int | String */ nonce;

  final bool? tts;

  final List<Embed>? embeds;

  final AllowedMentions? allowedMentions;

  final Snowflake? replyId;

  final bool? requireReplyToExist;

  // TODO
  //final List<ComponentBuilder>?> components;

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
    this.stickerIds,
    this.attachments,
    this.suppressEmbeds,
    this.suppressNotifications,
  });

  @override
  Map<String, Object?> build() {
    List<Map<String, Object?>>? embeds;

    if (this.embeds != null) {
      embeds = [
        for (final embed in this.embeds!)
          {
            if (embed.title != null) 'title': embed.title,
            if (embed.description != null) 'description': embed.description,
            if (embed.url != null) 'url': embed.url.toString(),
            if (embed.timestamp != null) 'timestamp': embed.timestamp!.toIso8601String(),
            if (embed.color != null) 'color': embed.color!.value,
            if (embed.footer != null)
              'footer': {
                'text': embed.footer!.text,
                if (embed.footer!.iconUrl != null) 'icon_url': embed.footer!.iconUrl!.toString(),
                if (embed.footer!.proxiedIconUrl != null) 'proxy_icon_url': embed.footer!.proxiedIconUrl!.toString(),
              },
            if (embed.image != null)
              'image': {
                'url': embed.image!.url.toString(),
                if (embed.image!.proxiedUrl != null) 'proxy_url': embed.image!.proxiedUrl!.toString(),
                if (embed.image!.width != null) 'width': embed.image!.width,
                if (embed.image!.height != null) 'height': embed.image!.height,
              },
            if (embed.thumbnail != null)
              'thumbnail': {
                'url': embed.thumbnail!.url.toString(),
                if (embed.thumbnail!.proxiedUrl != null) 'proxy_url': embed.thumbnail!.proxiedUrl!.toString(),
                if (embed.thumbnail!.width != null) 'width': embed.thumbnail!.width,
                if (embed.thumbnail!.height != null) 'height': embed.thumbnail!.height,
              },
            if (embed.video != null)
              'video': {
                'url': embed.video!.url.toString(),
                if (embed.video!.proxiedUrl != null) 'proxy_url': embed.video!.proxiedUrl!.toString(),
                if (embed.video!.width != null) 'width': embed.video!.width,
                if (embed.video!.height != null) 'height': embed.video!.height,
              },
            if (embed.provider != null)
              'provider': {
                if (embed.provider!.name != null) 'name': embed.provider!.name,
                if (embed.provider!.url != null) 'url': embed.provider!.url!.toString(),
              },
            if (embed.author != null)
              'author': {
                'name': embed.author!.name,
                if (embed.author!.url != null) 'url': embed.author!.url!.toString(),
                if (embed.author!.iconUrl != null) 'icon_url': embed.author!.iconUrl!.toString(),
                if (embed.author!.proxyIconUrl != null) 'proxy_icon_url': embed.author!.iconUrl!.toString(),
              },
            if (embed.fields != null)
              'fields': [
                for (final field in embed.fields!)
                  {
                    'name': field.name,
                    'value': field.value,
                    'inline': field.inline,
                  },
              ],
          }
      ];
    }

    return {
      if (content != null) 'content': content,
      if (nonce != null) 'nonce': nonce,
      if (tts != null) 'tts': tts,
      if (embeds != null) 'embeds': embeds,
      if (allowedMentions != null) 'allowed_mentions': allowedMentions!.build(),
      if (replyId != null)
        'message_reference': {
          'message_id': replyId.toString(),
          if (requireReplyToExist != null) 'fail_if_not_exists': requireReplyToExist,
        },
      if (stickerIds != null) 'sticker_ids': stickerIds!.map((e) => e.toString()).toList(),
      if (attachments != null) 'attachments': attachments!.map((e) => e.build()).toList(),
      if (suppressEmbeds != null || suppressNotifications != null)
        'flags': (suppressEmbeds == true ? MessageFlags.suppressEmbeds.value.toInt() : 0) |
            (suppressNotifications == true ? MessageFlags.suppressNotifications.value.toInt() : 0),
    };
  }
}

class MessageUpdateBuilder extends UpdateBuilder<Message> {
  final String? content;

  final List<Embed>? embeds;

  final bool? suppressEmbeds;

  final AllowedMentions? allowedMentions;

  // TODO
  //final List<ComponentBuilder>? components;

  final List<AttachmentBuilder>? attachments;

  MessageUpdateBuilder({
    this.content = sentinelString,
    this.embeds = sentinelList,
    this.suppressEmbeds,
    this.allowedMentions,
    this.attachments = sentinelList,
  });
  @override
  Map<String, Object?> build() {
    List<Map<String, Object?>>? embeds = sentinelList;

    if (!identical(this.embeds, sentinelList)) {
      if (this.embeds == null) {
        embeds = null;
      } else {
        embeds = [
          for (final embed in this.embeds!)
            {
              if (embed.title != null) 'title': embed.title,
              if (embed.description != null) 'description': embed.description,
              if (embed.url != null) 'url': embed.url.toString(),
              if (embed.timestamp != null) 'timestamp': embed.timestamp!.toIso8601String(),
              if (embed.color != null) 'color': embed.color!.value,
              if (embed.footer != null)
                'footer': {
                  'text': embed.footer!.text,
                  if (embed.footer!.iconUrl != null) 'icon_url': embed.footer!.iconUrl!.toString(),
                  if (embed.footer!.proxiedIconUrl != null) 'proxy_icon_url': embed.footer!.proxiedIconUrl!.toString(),
                },
              if (embed.image != null)
                'image': {
                  'url': embed.image!.url.toString(),
                  if (embed.image!.proxiedUrl != null) 'proxy_url': embed.image!.proxiedUrl!.toString(),
                  if (embed.image!.width != null) 'width': embed.image!.width,
                  if (embed.image!.height != null) 'height': embed.image!.height,
                },
              if (embed.thumbnail != null)
                'thumbnail': {
                  'url': embed.thumbnail!.url.toString(),
                  if (embed.thumbnail!.proxiedUrl != null) 'proxy_url': embed.thumbnail!.proxiedUrl!.toString(),
                  if (embed.thumbnail!.width != null) 'width': embed.thumbnail!.width,
                  if (embed.thumbnail!.height != null) 'height': embed.thumbnail!.height,
                },
              if (embed.video != null)
                'video': {
                  'url': embed.video!.url.toString(),
                  if (embed.video!.proxiedUrl != null) 'proxy_url': embed.video!.proxiedUrl!.toString(),
                  if (embed.video!.width != null) 'width': embed.video!.width,
                  if (embed.video!.height != null) 'height': embed.video!.height,
                },
              if (embed.provider != null)
                'provider': {
                  if (embed.provider!.name != null) 'name': embed.provider!.name,
                  if (embed.provider!.url != null) 'url': embed.provider!.url!.toString(),
                },
              if (embed.author != null)
                'author': {
                  'name': embed.author!.name,
                  if (embed.author!.url != null) 'url': embed.author!.url!.toString(),
                  if (embed.author!.iconUrl != null) 'icon_url': embed.author!.iconUrl!.toString(),
                  if (embed.author!.proxyIconUrl != null) 'proxy_icon_url': embed.author!.iconUrl!.toString(),
                },
              if (embed.fields != null)
                'fields': [
                  for (final field in embed.fields!)
                    {
                      'name': field.name,
                      'value': field.value,
                      'inline': field.inline,
                    },
                ],
            }
        ];
      }
    }

    return {
      if (!identical(content, sentinelString)) 'content': content,
      if (!identical(embeds, sentinelList)) 'embeds': embeds,
      if (allowedMentions != null) 'allowed_mentions': allowedMentions!.build(),
      if (!identical(attachments, sentinelList)) 'attachments': attachments!.map((e) => e.build()).toList(),
      if (suppressEmbeds != null) 'flags': (suppressEmbeds == true ? MessageFlags.suppressEmbeds.value.toInt() : 0),
    };
  }
}
