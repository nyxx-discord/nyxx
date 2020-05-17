part of nyxx;

/// Cache for Channels
class ChannelCache extends Cache<Snowflake, Channel> {
  ChannelCache._new() {
    this._cache = {};
  }

  /// Allows to get channel and cast to [E] in one operation.
  E? get<E>(Snowflake id) => _cache[id] as E?;

  @override
  Future<void> dispose() async {
    _cache.forEach((_, v) {
      if (v is MessageChannel) v.dispose();
    });

    _cache.clear();
  }
}
