part of nyxx_interactions;

/// Manually define command syncing rules
class LockFileCommandSync implements ICommandsSync {
  const LockFileCommandSync();

  @override
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands) async {
    final lockFile = File("./nyxx_interactions.lock");
    final commandsLockFileData = commands.map((c) => new _LockfileCommand(c.name, c.guild, c.defaultPermissions,
        c.permissions?.map((p) => new _LockfilePermission(p._type, p.id, p.hasPermission)) ?? []));
    if (!lockFile.existsSync()) {
      await lockFile.writeAsString(jsonEncode(commandsLockFileData));
      return true;
    }

    final lockfileData = jsonDecode(lockFile.readAsStringSync()) as _LockfileCommand;

    if (commandsLockFileData == lockfileData) {
      return false;
    }

    await lockFile.writeAsString(jsonEncode(commandsLockFileData));
    return true;
  }
}

class _LockfileCommand {
  final String name;
  final Snowflake? guild;
  final bool defaultPermissions;
  final Iterable<_LockfilePermission> permissions;

  _LockfileCommand(this.name, this.guild, this.defaultPermissions, this.permissions);

  @override
  bool operator ==(Object other) {
    if (other is! _LockfileCommand) {
      return super == other;
    }

    if (other.defaultPermissions != this.defaultPermissions ||
        other.name != this.name ||
        other.guild != this.guild ||
        other.defaultPermissions != this.defaultPermissions) {
      return false;
    }

    return true;
  }
}

class _LockfilePermission {
  final int permissionType;
  final Snowflake? permissionEntityId;
  final bool permissionsGranted;

  const _LockfilePermission(this.permissionType, this.permissionEntityId, this.permissionsGranted);

  @override
  bool operator ==(Object other) {
    if (other is! _LockfilePermission) {
      return super == other;
    }

    if (other.permissionType != this.permissionType ||
        other.permissionEntityId != this.permissionEntityId ||
        other.permissionsGranted != this.permissionsGranted) {
      return false;
    }

    return true;
  }
}
