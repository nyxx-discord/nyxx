import 'package:nyxx/src/models/gateway/event.dart';

/// {@template application_command_permissions_update_event}
/// Emitted when the permissions for an application command are updated.
/// {@endtemplate}
class ApplicationCommandPermissionsUpdateEvent extends DispatchEvent {
  // TODO
  //final ApplicationCommandPermissions permissions;

  /// {@macro application_command_permissions_update_event}
  ApplicationCommandPermissionsUpdateEvent({required super.gateway});
}
