part of nyxx;

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

  /// Raw content returned by API
  Map<String, dynamic> raw;
  
  VoiceRegion._new(this.raw) {
    this.id = raw['id'];
    this.name = raw['name'];
    this.vip = raw['vip'];
    this.optimal = raw['optimal'];
    this.deprecated = raw['deprecated'];
    this.custom = raw['custom'];
  }
}