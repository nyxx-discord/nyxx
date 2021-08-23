part of nyxx_interactions;

/// Used to define permissions for a particular command.
abstract class ICommandPermissionBuilder extends Builder {
  late final int _type;

  /// The ID of the Role or User to give permissions too
  final Snowflake id;

  /// Does the role have permission to use the command
  final bool hasPermission;

  ICommandPermissionBuilder(this.id, {this.hasPermission = true});

  /// A permission for a single user that can be used in [SlashCommandBuilder]
  factory ICommandPermissionBuilder.user(Snowflake id, {bool hasPermission = true}) =>
      UserCommandPermissionBuilder(id, hasPermission: hasPermission);

  /// A permission for a single role that can be used in [SlashCommandBuilder]
  factory ICommandPermissionBuilder.role(Snowflake id, {bool hasPermission = true}) =>
      RoleCommandPermissionBuilder(id, hasPermission: hasPermission);
}

/// A permission for a single role that can be used in [SlashCommandBuilder]
class RoleCommandPermissionBuilder extends ICommandPermissionBuilder {
  @override
  late final int _type = 1;

  /// A permission for a single role that can be used in [SlashCommandBuilder]
  RoleCommandPermissionBuilder(Snowflake id, {bool hasPermission = true}) : super(id, hasPermission: hasPermission);

  @override
  RawApiMap build() => {"id": this.id.toString(), "type": this._type, "permission": this.hasPermission};
}

/// A permission for a single user that can be used in [SlashCommandBuilder]
class UserCommandPermissionBuilder extends ICommandPermissionBuilder {
  @override
  late final int _type = 2;

  /// A permission for a single user that can be used in [SlashCommandBuilder]
  UserCommandPermissionBuilder(Snowflake id, {bool hasPermission = true}) : super(id, hasPermission: hasPermission);

  @override
  RawApiMap build() => {"id": this.id.toString(), "type": this._type, "permission": this.hasPermission};
}
