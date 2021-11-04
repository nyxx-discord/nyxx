part of nyxx;

/// Cache for Channels
class ChannelCache extends Cache<Snowflake, IChannel> {
  ChannelCache._new() {
    this._cache = {};
  }

  /// Allows to get channel and cast to [E] in one operation.
  E? get<E>(Snowflake id) => _cache[id] as E?;

  @override
  Future<void> dispose() async {
    _cache.clear();
  }
}
