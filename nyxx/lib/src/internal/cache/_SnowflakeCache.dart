part of nyxx;

class _SnowflakeCache<T> extends Cache<Snowflake, T> {
  _SnowflakeCache() {
    this._cache = Map();
  }

  @override
  Future<void> dispose() => Future(() {
    if (T is Disposable) {
      _cache.forEach((_, v) => (v as Disposable).dispose());
    }

    _cache.clear();
  });
}
