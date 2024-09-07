import 'package:nyxx/src/gateway/shard.dart';
import 'package:nyxx/src/models/gateway/gateway.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// The base class for all exceptions thrown by nyxx.
class NyxxException implements Exception {
  /// The message for this exception.
  final String message;

  /// Create a new [NyxxException] with the provided [message].
  NyxxException(this.message);

  @override
  String toString() => message;
}

/// An exception thrown when an unexpected event is received on the Gateway.
class InvalidEventException extends NyxxException {
  /// Create a new [InvalidEventException] with the provided [message].
  InvalidEventException(String message) : super('Invalid gateway event: $message');
}

/// An exception thrown when a member already exists in a guild.
class MemberAlreadyExistsException extends NyxxException {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the member.
  final Snowflake memberId;

  /// Create a new [MemberAlreadyExistsException].
  MemberAlreadyExistsException(this.guildId, this.memberId) : super('Member $memberId already exists in guild $guildId');
}

/// An exception thrown when a role is not found in a guild.
class RoleNotFoundException extends NyxxException {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the role.
  final Snowflake roleId;

  /// Create a new [RoleNotFoundException].
  RoleNotFoundException(this.guildId, this.roleId) : super('Role $roleId not found in guild $guildId');
}

/// An exception thrown when a integration is not found in a guild.
class IntegrationNotFoundException extends NyxxException {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the integration.
  final Snowflake integrationId;

  /// Create a new [IntegrationNotFoundException].
  IntegrationNotFoundException(this.guildId, this.integrationId) : super('Integration $integrationId not found in guild $guildId');
}

/// An exception thrown when an audit log entry is not found in a guild.
class AuditLogEntryNotFoundException extends NyxxException {
  /// The ID of the guild.
  final Snowflake guildId;

  /// The ID of the audit log entry.
  final Snowflake auditLogEntryId;

  /// Create a new [AuditLogEntryNotFoundException].
  AuditLogEntryNotFoundException(this.guildId, this.auditLogEntryId) : super('Audit log entry $auditLogEntryId not found in guild $guildId');
}

/// An exception thrown when an entitlement is not found for an application.
class EntitlementNotFoundException extends NyxxException {
  /// The ID of the application.
  final Snowflake applicationId;

  /// The ID of the entitlement.
  final Snowflake entitlementId;

  /// Create a new [EntitlementNotFoundException].
  EntitlementNotFoundException(this.applicationId, this.entitlementId) : super('Entitlement $entitlementId not found for application $applicationId');
}

/// An exception thrown when an SKU is not found for an application.
class SkuNotFoundException extends NyxxException {
  /// The ID of the application.
  final Snowflake applicationId;

  /// The ID of the sku.
  final Snowflake skuId;

  /// Create a new [skuNotFoundException].
  SkuNotFoundException(this.applicationId, this.skuId) : super('SKU $skuId not found for application $applicationId');
}

/// An error thrown when a shard disconnects unexpectedly.
class ShardDisconnectedError extends Error {
  /// The shard that was disconnected.
  final Shard shard;

  /// Create a new [ShardDisconnectedError].
  ShardDisconnectedError(this.shard);

  @override
  String toString() => 'Shard ${shard.id} disconnected unexpectedly';
}

/// An error thrown when the number of remaining sessions becomes too low.
///
/// The threshold for this can be configured in [GatewayClientOptions.minimumSessionStarts].
class OutOfRemainingSessionsError extends Error {
  /// The [GatewayBot] containing the information that triggered the error.
  final GatewayBot gatewayBot;

  /// Create a new [OutOfRemainingSessionsError].
  OutOfRemainingSessionsError(this.gatewayBot);

  @override
  String toString() => 'Out of remaining session starts (${gatewayBot.sessionStartLimit.remaining} left)';
}

/// An error thrown when [MessageResponse.acknowledge] is called on an already acknowledged interaction.
class AlreadyAcknowledgedError extends Error {
  /// The interaction that was acknowledged.
  final MessageResponse<dynamic> interaction;

  /// Create a new [AlreadyAcknowledgedError].
  AlreadyAcknowledgedError(this.interaction);

  @override
  String toString() => 'Interaction has already been acknowledged';
}

/// An error thrown when [MessageResponse.respond] is called on an interaction that has already been responded to.
class AlreadyRespondedError extends AlreadyAcknowledgedError {
  /// Create a new [AlreadyRespondedError].
  AlreadyRespondedError(super.interaction);

  @override
  String toString() => 'Interaction has already been responded to';
}

/// An error thrown when an issue with a client's plugin is encountered.
class PluginError extends Error {
  /// The message for this [PluginError].
  final String message;

  /// Create a new [PluginError].
  PluginError(this.message);

  @override
  String toString() => message;
}

/// An error thrown when the client is closed while an operation is pending, or when an already closed client is used.
class ClientClosedError extends Error {
  @override
  String toString() => 'Client is closed';
}
