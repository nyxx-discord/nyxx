import 'package:nyxx/src/builders/application_command.dart';
import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/component.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/models/message/message.dart';

class InteractionResponseBuilder extends CreateBuilder<InteractionResponseBuilder> {
  final InteractionCallbackType type;

  final dynamic data;

  InteractionResponseBuilder({required this.type, required this.data});

  factory InteractionResponseBuilder.pong() => InteractionResponseBuilder(type: InteractionCallbackType.pong, data: null);

  factory InteractionResponseBuilder.channelMessage(MessageBuilder message) => InteractionResponseBuilder(
        type: InteractionCallbackType.channelMessageWithSource,
        data: message,
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

enum InteractionCallbackType {
  pong._(1),
  channelMessageWithSource._(4),
  deferredChannelMessageWithSource._(5),
  deferredUpdateMessage._(6),
  updateMessage._(7),
  applicationCommandAutocompleteResult._(8),
  modal._(9);

  final int value;

  const InteractionCallbackType._(this.value);
}

class ModalBuilder extends CreateBuilder<ModalBuilder> {
  final String customId;

  final String title;

  final List<TextInputBuilder> components;

  ModalBuilder({required this.customId, required this.title, required this.components});

  @override
  Map<String, Object?> build() => {
        'custom_id': customId,
        'title': title,
        'components': components.map((e) => e.build()).toList(),
      };
}
