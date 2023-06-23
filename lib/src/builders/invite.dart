import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/snowflake.dart';

class InviteBuilder extends CreateBuilder<Invite> {
  final Duration? maxAge;

  final int? maxUses;

  final bool? isTemporary;

  final bool? isUnique;

  final TargetType? targetType;

  final Snowflake? targetUserId;

  final Snowflake? targetApplicationId;

  InviteBuilder({
    this.maxAge = sentinelDuration,
    this.maxUses,
    this.isTemporary,
    this.isUnique,
    this.targetType,
    this.targetUserId,
    this.targetApplicationId,
  });

  @override
  Map<String, Object?> build() => {
        if (!identical(maxAge, sentinelDuration)) 'max_age': maxAge == null ? 0 : maxAge?.inSeconds,
        if (maxUses != null) 'max_uses': maxUses,
        if (isTemporary != null) 'temporary': isTemporary,
        if (isUnique != null) 'unique': isUnique,
        if (targetType != null) 'target_type': targetType!.value,
        if (targetUserId != null) 'target_user_id': targetUserId!.toString(),
        if (targetApplicationId != null) 'target_application_id': targetApplicationId!.toString(),
      };
}
