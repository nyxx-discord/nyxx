part of nyxx;

/// Represents voice region on which discord guild takes place
class VoiceRegion {
  /// Unique id for region
  String id;

  /// Name of the region
  String name;

  /// True if this is a vip-only server
  bool vip;

  /// True for a single server that is closest to the current user's client
  bool optimal;

  /// Whether this is a deprecated voice region (avoid switching to these)
  bool deprecated;

  /// Whether this is a custom voice region (used for events/etc)
  bool custom;

  VoiceRegion._new(Map<String, dynamic> raw) {
    this.id = raw['id'] as String;
    this.name = raw['name'] as String;
    this.vip = raw['vip'] as bool;
    this.optimal = raw['optimal'] as bool;
    this.deprecated = raw['deprecated'] as bool;
    this.custom = raw['custom'] as bool;
  }
}
