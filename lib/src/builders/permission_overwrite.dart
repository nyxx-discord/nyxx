import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';

class PermissionOverwriteBuilder extends CreateBuilder<PermissionOverwrite> {
  final Snowflake id;

  final PermissionOverwriteType type;

  final Permissions? allow;

  final Permissions? deny;

  PermissionOverwriteBuilder({required this.id, required this.type, this.allow, this.deny});

  @override
  Map<String, Object?> build() => {
        'id': id.toString(),
        'type': type.value,
        if (allow != null) 'allow': allow!.value.toString(),
        if (deny != null) 'deny': deny!.value.toString(),
      };
}
