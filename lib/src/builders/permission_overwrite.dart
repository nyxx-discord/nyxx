import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class PermissionOverwriteBuilder extends CreateBuilder<PermissionOverwrite> {
  final Snowflake id;

  final PermissionOverwriteType type;

  final Flags<Permissions>? allow;

  final Flags<Permissions>? deny;

  PermissionOverwriteBuilder({required this.id, required this.type, this.allow, this.deny});

  @override
  Map<String, Object?> build() => {
        'type': type.value,
        if (allow != null) 'allow': allow!.value.toString(),
        if (deny != null) 'deny': deny!.value.toString(),
      };
}
