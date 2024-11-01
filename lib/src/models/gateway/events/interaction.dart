import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/interaction.dart';

/// {@template interaction_create_event}
/// Emitted when an interaction is received by the client.
/// {@endtemplate}
class InteractionCreateEvent<T extends Interaction<dynamic>> extends DispatchEvent {
  // The created interaction.
  final T interaction;

  /// {@macro interaction_create_event}
  /// @nodoc
  InteractionCreateEvent({required super.gateway, required this.interaction});
}
