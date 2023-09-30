import 'package:nyxx/src/builders/application_command.dart';
import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/component.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/models/message/message.dart';

class InteractionResponseBuilder extends CreateBuilder<InteractionResponseBuilder> {
  InteractionCallbackType type;

  dynamic data;

  InteractionResponseBuilder({required this.type, required this.data});

  factory InteractionResponseBuilder.pong() => InteractionResponseBuilder(type: InteractionCallbackType.pong, data: null);

  factory InteractionResponseBuilder.channelMessage(MessageBuilder message, {bool? isEphemeral}) => InteractionResponseBuilder(
        type: InteractionCallbackType.channelMessageWithSource,
        data: _EphemeralMessageBuilder(
          content: message.content,
          nonce: message.nonce,
          tts: message.tts,
          embeds: message.embeds,
          allowedMentions: message.allowedMentions,
          replyId: message.replyId,
          requireReplyToExist: message.requireReplyToExist,
          components: message.components,
          stickerIds: message.stickerIds,
          attachments: message.attachments,
          suppressEmbeds: message.suppressEmbeds,
          suppressNotifications: message.suppressNotifications,
          isEphemeral: isEphemeral,
        ),
      );

  factory InteractionResponseBuilder.deferredChannelMessage({bool? isEphemeral}) => InteractionResponseBuilder(
        type: InteractionCallbackType.deferredChannelMessageWithSource,
        data: isEphemeral == null ? null : {'flags': (isEphemeral ? MessageFlags.ephemeral.value : 0)},
      );

  factory InteractionResponseBuilder.updateMessage(MessageUpdateBuilder message) => InteractionResponseBuilder(
        type: InteractionCallbackType.updateMessage,
        data: message,
      );

  factory InteractionResponseBuilder.deferredUpdateMessage() => InteractionResponseBuilder(
        type: InteractionCallbackType.deferredUpdateMessage,
        data: null,
      );

  factory InteractionResponseBuilder.autocompleteResult(List<CommandOptionChoiceBuilder<dynamic>> choices) => InteractionResponseBuilder(
        type: InteractionCallbackType.applicationCommandAutocompleteResult,
        data: choices,
      );

  factory InteractionResponseBuilder.modal(ModalBuilder modal) => InteractionResponseBuilder(type: InteractionCallbackType.modal, data: modal);

  factory InteractionResponseBuilder.premiumRequired() => InteractionResponseBuilder(type: InteractionCallbackType.premiumRequired, data: null);

  @override
  Map<String, Object?> build() {
    final builtData = switch (data) {
      final Builder<dynamic> builder => builder.build(),
      final List<Builder<dynamic>> builders => builders.map((e) => e.build()).toList(),
      Map<String, Object?>() || List<Object?>() || String() || int() || double() || bool() || null => data,
      _ => throw ArgumentError.value(data, 'data', 'must be a Builder, a List<Builder> or a JSON value')
    };

    return {
      'type': type.value,
      'data': builtData,
    };
  }
}

class _EphemeralMessageBuilder extends MessageBuilder {
  bool? isEphemeral;

  _EphemeralMessageBuilder({
    required super.content,
    required super.nonce,
    required super.tts,
    required super.embeds,
    required super.allowedMentions,
    required super.replyId,
    required super.requireReplyToExist,
    required super.components,
    required super.stickerIds,
    required super.attachments,
    required super.suppressEmbeds,
    required super.suppressNotifications,
    required this.isEphemeral,
  });

  @override
  Map<String, Object?> build() {
    final built = super.build();

    if (isEphemeral != null) {
      built['flags'] = (built['flags'] as int? ?? 0) | (isEphemeral == true ? MessageFlags.ephemeral.value : 0);
    }

    return built;
  }
}

enum InteractionCallbackType {
  pong._(1),
  channelMessageWithSource._(4),
  deferredChannelMessageWithSource._(5),
  deferredUpdateMessage._(6),
  updateMessage._(7),
  applicationCommandAutocompleteResult._(8),
  modal._(9),
  premiumRequired._(10);

  final int value;

  const InteractionCallbackType._(this.value);
}

class ModalBuilder extends CreateBuilder<ModalBuilder> {
  String customId;

  String title;

  List<ActionRowBuilder> components;

  ModalBuilder({required this.customId, required this.title, required this.components});

  @override
  Map<String, Object?> build() => {
        'custom_id': customId,
        'title': title,
        'components': components.map((e) => e.build()).toList(),
      };
}
