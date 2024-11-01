import 'package:nyxx/src/models/commands/application_command_permissions.dart';
import 'package:nyxx/src/models/gateway/event.dart';

/// {@template application_command_permissions_update_event}
/// Emitted when the permissions for an application command are updated.
/// {@endtemplate}
class ApplicationCommandPermissionsUpdateEvent extends DispatchEvent {
  /// The permissions that were updated.
  final CommandPermissions permissions;

  /// The permissions as they were cached before the update.
  final CommandPermissions? oldPermissions;

  /// {@macro application_command_permissions_update_event}
  /// @nodoc
  ApplicationCommandPermissionsUpdateEvent({required super.gateway, required this.permissions, required this.oldPermissions});
}
