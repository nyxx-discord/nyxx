part of nyxx_interactions;

/// Used to define permissions for a particular command.
class CommandPermissionBuilder extends Builder {
  /// The role ID to change the permissions for
  Snowflake? role;

  /// The user'd ID to change the permissions for
  Snowflake? user;

  /// Does the role have permission to use the command
  final bool hasPermission;

  /// A permission for a single user that can be used in [SlashCommandBuilder]
  CommandPermissionBuilder.forUser(this.user, {this.hasPermission = true});

  /// A permission for a single role that can be used in [SlashCommandBuilder]
  CommandPermissionBuilder.forRole(this.role, {this.hasPermission = true});

  @override
  Map<String, dynamic> build() => {
        "id": this.role != null ? this.role.toString() : this.user.toString(),
        "type": this.role != null ? 1 : 2,
        "permission": this.hasPermission
      };
}
