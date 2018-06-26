part of discord;

/// Handles caching of cooldown
class CooldownCache {
  List<CacheEntry> _cache;

  /// Constructor sets up empty cache and starts garbage collector.
  CooldownCache() {
    _cache = [];

    new Timer.periodic(const Duration(minutes:30), (Timer t) {
      int now = new DateTime.now().millisecondsSinceEpoch;

      _cache.removeWhere((item) => now - item.lastUsed >= 1800000);
    });
  }

  /// Checks if user can execute given command at given time
  Future<bool> canExecute(
      String userId, String commandName, int desiredCooldown) async {
    int now = new DateTime.now().millisecondsSinceEpoch;

    var entryList = _cache.where(
        (item) => item.userId == userId && item.commandName == commandName);
    CacheEntry entry = entryList.isEmpty ? null : entryList.first;

    if (entry == null) {
      var newEntry = new CacheEntry(userId, commandName, now);
      _cache.add(newEntry);
      return true;
    }

    if (entry.lastUsed + desiredCooldown < now) {
      entry.lastUsed = now;
      var pos = _cache.indexOf(entry);
      _cache.removeAt(pos);
      _cache.add(entry);
      return true;
    }

    return false;
  }
}

/// Single Command Cooldown Cache entry.
class CacheEntry {
  /// Id of user which requested command
  String userId;

  /// Name of requested command
  String commandName;

  /// Timestamp user last used command
  int lastUsed;

  /// Create cache entry
  CacheEntry(this.userId, this.commandName, this.lastUsed);
}
