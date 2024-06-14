import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template sku}
/// A premium offering that can be made available to your application's users or guilds.
/// {@endtemplate}
class Sku with ToStringHelper {
  /// The [Manager] for this SKU.
  final ApplicationManager manager;

  /// This SKU's ID.
  final Snowflake id;

  /// This SKU's type.
  final SkuType type;

  /// The ID of the application this SKU belongs to.
  final Snowflake applicationId;

  /// The name of this SKU.
  final String name;

  /// The URL slug for this SKU.
  final String slug;

  /// This SKU's flags.
  final SkuFlags flags;

  /// {@macro sku}
  /// @nodoc
  Sku({
    required this.manager,
    required this.id,
    required this.type,
    required this.applicationId,
    required this.name,
    required this.slug,
    required this.flags,
  });

  /// The application this SKU belongs to.
  PartialApplication get application => PartialApplication(id: applicationId, manager: manager);
}

/// The type of an [Sku].
final class SkuType extends EnumLike<int, SkuType> {
  /// Durable one-time purchase.
  static const durable = SkuType(2);

  /// Consumable one-time purchase.
  static const consumable = SkuType(3);

  /// Subscription.
  static const subscription = SkuType(5);

  /// Subscription group.
  static const subscriptionGroup = SkuType(6);

  /// @nodoc
  const SkuType(super.value);

  SkuType.parse(int value) : this(value);
}

/// Flags applied to an [Sku].
class SkuFlags extends Flags<SkuFlags> {
  /// The SKU is available for purchase.
  static const available = Flag<SkuFlags>.fromOffset(2);

  /// The SKU is a guild subscription.
  static const guildSubscription = Flag<SkuFlags>.fromOffset(7);

  /// The SKU is a user subscription.
  static const userSubscription = Flag<SkuFlags>.fromOffset(8);

  /// Create a new [SkuFlags].
  SkuFlags(super.value);

  /// Whether this set of flags has the [available] flag set.
  bool get isAvailable => has(available);

  /// Whether this set of flags has the [guildSubscription] flag set.
  bool get isGuildSubscription => has(guildSubscription);

  /// Whether this set of flags has the [userSubscription] flag set.
  bool get isUserSubscription => has(userSubscription);
}
