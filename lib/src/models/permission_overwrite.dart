import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template permission_overwrite}
/// A set of overwrites to apply to permissions within a specific channel.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#overwrite-object
/// {@endtemplate}
class PermissionOverwrite with ToStringHelper {
  /// The id of the entity the permission changes will apply to.
  ///
  /// This can be the ID of a [Member] or of a [Role], depending on [type].
  final Snowflake id;

  /// The type of permission overwrite.
  final PermissionOverwriteType type;

  /// Extra permissions allowed relative to the base permissions.
  ///
  /// {@template permission_overwrite_field}
  /// External references:
  /// * [Permissions]
  /// * Computing permissions: https://discord.com/developers/docs/topics/permissions#permission-overwrites
  /// {@endtemplate}
  final Permissions allow;

  /// Extra permissions denied relative to the base permissions.
  ///
  /// {@macro permission_overwrite_field}
  final Permissions deny;

  /// {@macro permission_overwrite}
  /// @nodoc
  PermissionOverwrite({
    required this.id,
    required this.type,
    required this.allow,
    required this.deny,
  });
}

/// The type of a permission overwrite.
final class PermissionOverwriteType extends EnumLike<int> {
  /// The overwrite applies to a [Role]'s permissions.
  static const role = PermissionOverwriteType._(0);

  /// The overwrite applies to a [Member]'s permissions.
  static const member = PermissionOverwriteType._(1);

  static const values = [role, member];

  const PermissionOverwriteType._(super.value);

  factory PermissionOverwriteType.parse(int value) => parseEnum(values, value);
}
