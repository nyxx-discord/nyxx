import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/events/event.dart';

/// {@template stage_instance_create_event}
/// Emitted when a stage instance is created.
/// {@endtemplate}
class StageInstanceCreateEvent extends DispatchEvent {
  /// The updated stage instance.
  final StageInstance instance;

  /// {@macro stage_instance_create_event}
  /// @nodoc
  StageInstanceCreateEvent({required super.client, required this.instance});
}

/// {@template stage_instance_update_event}
/// Emitted when a stage instance is updated.
/// {@endtemplate}
class StageInstanceUpdateEvent extends DispatchEvent {
  /// The stage instance as it was cached before the update.
  final StageInstance? oldInstance;

  /// The updated stage instance.
  final StageInstance instance;

  /// {@macro stage_instance_update_event}
  /// @nodoc
  StageInstanceUpdateEvent({required super.client, required this.oldInstance, required this.instance});
}

/// {@template stage_instance_delete_event}
/// Emitted when a stage instance is deleted.
/// {@endtemplate}
class StageInstanceDeleteEvent extends DispatchEvent {
  /// The stage instance that was deleted.
  final StageInstance instance;

  /// {@macro stage_instance_delete_event}
  /// @nodoc
  StageInstanceDeleteEvent({required super.client, required this.instance});
}
