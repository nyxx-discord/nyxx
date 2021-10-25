import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';

abstract class IPermissionsOverrides implements SnowflakeEntity, Convertable<PermissionOverrideBuilder> {
  /// Type of entity. Either 0 (role) or 1 (member)
  int get type;

  /// Permissions
  Permissions get permissions;

  /// Value of permissions allowed
  int get allow;

  /// Value of permissions denied
  int get deny;
}

/// Holds permissions overrides for channel
class PermissionsOverrides extends SnowflakeEntity implements IPermissionsOverrides {
  /// Type of entity. Either 0 (role) or 1 (member)
  @override
  late final int type;

  /// Permissions
  @override
  late final Permissions permissions;

  /// Value of permissions allowed
  @override
  late final int allow;

  /// Value of permissions denied
  @override
  late final int deny;

  /// Creates an instance of [PermissionsOverrides]
  PermissionsOverrides(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.allow = int.parse(raw["allow"] as String);
    this.deny = int.parse(raw["deny"] as String);

    this.permissions = Permissions.fromOverwrite(0, allow, deny);
    this.type = raw["type"] as int;
  }

  @override
  PermissionOverrideBuilder toBuilder() => PermissionOverrideBuilder.from(this.type, this.id, this.permissions);
}
