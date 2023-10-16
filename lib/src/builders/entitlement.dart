import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/snowflake.dart';

class TestEntitlementBuilder extends CreateBuilder<Entitlement> {
  Snowflake skuId;

  Snowflake ownerId;

  TestEntitlementType ownerType;

  TestEntitlementBuilder({required this.skuId, required this.ownerId, required this.ownerType});

  @override
  Map<String, Object?> build() => {
        'sku_id': skuId.toString(),
        'owner_id': ownerId.toString(),
        'owner_type': ownerType.value,
      };
}

enum TestEntitlementType {
  guildSubscription._(1),
  userSubscription._(2);

  final int value;

  const TestEntitlementType._(this.value);
}
