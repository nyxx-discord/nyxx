import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/gateway/event.dart';

/// {@template stage_instance_create_event}
/// Emitted when a stage instance is created.
/// {@endtemplate}
class StageInstanceCreateEvent extends DispatchEvent {
  final StageInstance instance;

  StageInstanceCreateEvent({required this.instance});
}

/// {@template stage_instance_update_event}
/// Emitted when a stage instance is updated.
/// {@endtemplate}
class StageInstanceUpdateEvent extends DispatchEvent {
  final StageInstance? oldInstance;

  final StageInstance instance;

  StageInstanceUpdateEvent({required this.oldInstance, required this.instance});
}

/// {@template stage_instance_delete_event}
/// Emitted when a stage instance is deleted.
/// {@endtemplate}
class StageInstanceDeleteEvent extends DispatchEvent {
  final StageInstance instance;

  StageInstanceDeleteEvent({required this.instance});
}
