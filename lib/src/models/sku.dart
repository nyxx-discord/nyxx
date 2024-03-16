import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/snowflake.dart';
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
enum SkuType {
  subscription._(5),
  subscriptionGroup._(6);

  final int value;

  const SkuType._(this.value);

  /// Parse an [SkuType] from an [int].
  ///
  /// The [value] must be a valid sku type.
  factory SkuType.parse(int value) => SkuType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown SKU type', value),
      );

  @override
  String toString() => 'SkuType($value)';
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
