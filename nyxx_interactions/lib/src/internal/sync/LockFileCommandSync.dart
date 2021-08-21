part of nyxx_interactions;

/// Manually define command syncing rules
class LockFileCommandSync implements ICommandsSync {
  const LockFileCommandSync();

  @override
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands) async {
    final lockFile = File("./nyxx_interactions.lock");
    final lockFileMapData = <String, String>{};

    commands.forEach(
      (c) {
        lockFileMapData[c.name] = new _LockfileCommand(
          c.name,
          c.description,
          c.guild,
          c.defaultPermissions,
          c.permissions?.map((p) => new _LockfilePermission(p._type, p.id, p.hasPermission)) ?? [],
          c.options.map((o) => new _LockfileOption(o.type.value, o.name, o.description, o.options ?? [])),
        ).generateHash();
      },
    );

    if (!lockFile.existsSync()) {
      await lockFile.writeAsString(jsonEncode(lockFileMapData));
      return true;
    }

    final lockfileData = jsonDecode(lockFile.readAsStringSync()) as _LockfileCommand;

    if (lockFileMapData == lockfileData) {
      return false;
    }

    await lockFile.writeAsString(jsonEncode(lockFileMapData));
    return true;
  }
}

class _LockfileCommand {
  final String name;
  final Snowflake? guild;
  final bool defaultPermissions;
  final Iterable<_LockfilePermission> permissions;
  final String description;
  final Iterable<_LockfileOption> options;

  _LockfileCommand(this.name, this.description, this.guild, this.defaultPermissions, this.permissions, this.options);

  String generateHash() => md5.convert(utf8.encode(jsonEncode(this))).toString();

  @override
  bool operator ==(Object other) {
    if (other is! _LockfileCommand) {
      return false;
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

class _LockfileOption {
  final int type;
  final String name;
  final String description;

  late final Iterable<_LockfileOption> options;

  _LockfileOption(this.type, this.name, this.description, Iterable<CommandOptionBuilder> options) {
    this.options = options.map(
      (o) => new _LockfileOption(
        o.type.value,
        o.name,
        o.description,
        o.options ?? [],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! _LockfileOption) {
      return false;
    }

    if (other.type != this.type || other.name != this.name || other.description != this.description) {
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
      return false;
    }

    if (other.permissionType != this.permissionType ||
        other.permissionEntityId != this.permissionEntityId ||
        other.permissionsGranted != this.permissionsGranted) {
      return false;
    }

    return true;
  }
}
