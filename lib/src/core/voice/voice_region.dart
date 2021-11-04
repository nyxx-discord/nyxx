import 'package:nyxx/src/typedefs.dart';

abstract class IVoiceRegion {
  /// Unique id for region
  String get id;

  /// Name of the region
  String get name;

  /// True if this is a vip-only server
  bool get vip;

  /// True for a single server that is closest to the current user's client
  bool get optimal;

  /// Whether this is a deprecated voice region (avoid switching to these)
  bool get deprecated;

  /// Whether this is a custom voice region (used for events/etc)
  bool get custom;
}

/// Represents voice region on which discord guild takes place
class VoiceRegion implements IVoiceRegion {
  /// Unique id for region
  @override
  late final String id;

  /// Name of the region
  @override
  late final String name;

  /// True if this is a vip-only server
  @override
  late final bool vip;

  /// True for a single server that is closest to the current user's client
  @override
  late final bool optimal;

  /// Whether this is a deprecated voice region (avoid switching to these)
  @override
  late final bool deprecated;

  /// Whether this is a custom voice region (used for events/etc)
  @override
  late final bool custom;

  /// Creates an instance of [VoiceRegion]
  VoiceRegion(RawApiMap raw) {
    id = raw["id"] as String;
    name = raw["name"] as String;
    vip = raw["vip"] as bool;
    optimal = raw["optimal"] as bool;
    deprecated = raw["deprecated"] as bool;
    custom = raw["custom"] as bool;
  }
}
