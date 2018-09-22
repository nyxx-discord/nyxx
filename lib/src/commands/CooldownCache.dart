part of nyxx.commands;

/// Handles caching of cooldown
class CooldownCache {
  Map<_CacheKey, int> _cache;

  /// Constructor sets up empty cache and starts garbage collector.
  CooldownCache(Duration roundupTime) {
    _cache = Map();

    Timer.periodic(roundupTime, (_) {
      int now = DateTime.now().millisecondsSinceEpoch;

      _cache.forEach((k, v) {
        if (now - v >= 1800000) _cache.remove(k);
      });
    });
  }

  /// Checks if user can execute given command at given time
  Future<bool> canExecute(
      Snowflake userId, String commandName, int desiredCooldown) {
    return Future.microtask<bool>(() {
      /// current date
      int now = DateTime.now().millisecondsSinceEpoch;
      var node = _CacheKey._new(userId, commandName);

      bool found = false;

      /// Search for entry
      if (_cache.containsKey(node)) found = true;

      /// If not found crete new, insert it and return
      if (!found) {
        _cache[node] = now;
        return true;
      }

      /// If found check if user can execute command
      if (_cache[node] + desiredCooldown < now) {
        _cache[node] = now;
        return true;
      }

      return false;
    });
  }
}

class _CacheKey {
  Snowflake _id;
  String _command;

  _CacheKey._new(this._id, this._command);

  @override
  bool operator ==(other) =>
      other is _CacheKey &&
      this._id == other._id &&
      this._command == other._command;

  @override
  int get hashCode =>
      ((17 * 37 + this._id.hashCode) * 37 + this._command.hashCode);
}
