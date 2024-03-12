import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/gateway/event.dart';

/// {@template entitlement_create_event}
/// Emitted when an entitlement is created.
/// {@endtemplate}
class EntitlementCreateEvent extends DispatchEvent {
  /// The entitlement that was created,
  final Entitlement entitlement;

  /// {@macro entitlement_create_event}
  /// @nodoc
  EntitlementCreateEvent({required super.gateway, required this.entitlement});
}

/// {@template entitlement_update_event}
/// Emitted when an entitlement is updated.
/// {@endtemplate}
class EntitlementUpdateEvent extends DispatchEvent {
  /// The updated entitlement.
  final Entitlement entitlement;

  /// The entitlement as it was cached before it was updated.
  final Entitlement? oldEntitlement;

  /// {@macro entitlement_update_event}
  /// @nodoc
  EntitlementUpdateEvent({required super.gateway, required this.entitlement, required this.oldEntitlement});
}

/// {@template entitlement_delete_event}
/// Emitted when an entitlement is deleted.
/// {@endtemplate}
class EntitlementDeleteEvent extends DispatchEvent {
  /// The entitlement that was deleted.
  final Entitlement entitlement;

  /// The entitlement as it was cached before it was deleted.
  final Entitlement? deletedEntitlement;

  /// {@macro entitlement_delete_event}
  /// @nodoc
  EntitlementDeleteEvent({required super.gateway, required this.entitlement, required this.deletedEntitlement});
}
