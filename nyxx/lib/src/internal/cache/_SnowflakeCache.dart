part of nyxx;

class _SnowflakeCache<T> extends Cache<Snowflake, T> {
  _SnowflakeCache() {
    this._cache = {};
  }

  @override
  Future<void> dispose() async {
    if (T is Disposable) {
      _cache.forEach((_, v) => (v as Disposable).dispose());
    }

    _cache.clear();
  }
}
