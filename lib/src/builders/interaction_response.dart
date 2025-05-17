import 'package:nyxx/src/builders/application_command.dart';
import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/component.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/utils/enum_like.dart';

class InteractionResponseBuilder extends CreateBuilder<InteractionResponseBuilder> {
  InteractionCallbackType type;

  dynamic data;

  InteractionResponseBuilder({required this.type, required this.data});

  factory InteractionResponseBuilder.pong() => InteractionResponseBuilder(type: InteractionCallbackType.pong, data: null);

  factory InteractionResponseBuilder.channelMessage(MessageBuilder message, {@Deprecated('Use message.flags') bool? isEphemeral}) {
    final builder = InteractionResponseBuilder(type: InteractionCallbackType.channelMessageWithSource, data: message);

    if (isEphemeral == true) {
      message.flags = (message.flags ?? MessageFlags(0)) | MessageFlags.ephemeral;
    }

    return builder;
  }

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
        data: {'choices': choices.map((e) => e.build()).toList()},
      );

  factory InteractionResponseBuilder.modal(ModalBuilder modal) => InteractionResponseBuilder(type: InteractionCallbackType.modal, data: modal);

  @Deprecated('Respond with ButtonStyle.premium button instead')
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

final class InteractionCallbackType extends EnumLike<int, InteractionCallbackType> {
  /// ACK a `Ping`
  static const pong = InteractionCallbackType(1);

  /// Respond to an interaction with a message.
  static const channelMessageWithSource = InteractionCallbackType(4);

  /// ACK an interaction and edit a response later, the user sees a loading state.
  static const deferredChannelMessageWithSource = InteractionCallbackType(5);

  /// For components, ACK an interaction and edit the original message later; the user does not see a loading state.
  static const deferredUpdateMessage = InteractionCallbackType(6);

  /// For components, edit the message the component was attached to.
  static const updateMessage = InteractionCallbackType(7);

  /// Respond to an autocomplete interaction with suggested choices.
  static const applicationCommandAutocompleteResult = InteractionCallbackType(8);

  /// Respond to an interaction with a popup modal.
  static const modal = InteractionCallbackType(9);

  /// [Deprecated](https://discord.com/developers/docs/change-log#premium-apps-new-premium-button-style-deep-linking-url-schemes); respond to an interaction with an upgrade button,
  /// only available for apps with [monetization](https://discord.com/developers/docs/monetization/overview) enabled.
  @Deprecated('Respond with ButtonStyle.premium button instead')
  static const premiumRequired = InteractionCallbackType(10);

  /// Launch the Activity associated with the app. Only available for apps with [Activities](https://discord.com/developers/docs/activities/overview) enabled.
  static const launchActivity = InteractionCallbackType(12);

  const InteractionCallbackType(super.value);
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
