part of nyxx;

/// Generic interface for caching entities.
/// Wraps [Map] interface and provides utilities for manipulating cache.
abstract class Cache<T, S> implements Disposable {
  late Map<T, S> _cache;

  /// Returns values of cache
  Iterable<S> get values => _cache.values;

  /// Returns key's values of cache
  Iterable<T> get keys => _cache.keys;

  /// Find one element in cache
  S? findOne(bool Function(S item) predicate) {
    // TODO: NNBD: try-catch in where
    try {
      return values.firstWhere(predicate);
    } on Exception {
      return null;
    }
  }

  /// Find matching items based of [predicate]
  Iterable<S> find(bool Function(S item) predicate) => values.where(predicate);

  /// Returns element with key [key]
  S? operator [](T key) => _cache.containsKey(key) ? _cache[key] : null;

  /// Sets [item] for [key]
  void operator []=(T key, S item) => _cache[key] = item;

  /// Puts [item] to collection if [key] doesn't exist in cache
  S addIfAbsent(T key, S item) {
    if (!_cache.containsKey(key)) return _cache[key] = item;
    return item;
  }

  /// Returns true if cache contains [key]
  bool hasKey(T key) => _cache.containsKey(key);

  /// Returns true if cache contains [value]
  bool hasValue(S value) => _cache.containsValue(value);

  /// Clear cache
  void invalidate() => _cache.clear();

  /// Add to cache [value] associated with [key]
  void add(T key, S value) => _cache[key] = value;

  /// Add [Map] to cache.
  void addMap(Map<T, S> mp) => _cache.addAll(mp);

  /// Remove [key] with associated with it value
  void remove(T key) => _cache.remove(key);

  /// Remove everything where [predicate] is true
  void removeWhere(bool Function(T key, S value) predicate) => _cache.removeWhere(predicate);

  /// Loop over elements from cache
  void forEach(void Function(T key, S value) f) => _cache.forEach(f);

  /// Take [count] elements from cache. Returns Iterable of cache values
  Iterable<S> take(int count) => values.take(count);

  /// Takes [count] last elements from cache. Returns Iterable of cache values
  Iterable<S> takeLast(int count) => values.toList().sublist(values.length - count);

  /// Get first element
  S? get first => _cache.values.first;

  /// Get last element
  S get last => _cache.values.last;

  /// Get number of elements from cache
  int get count => _cache.length;

  /// Returns cache as Map
  Map<T, S> get asMap => this._cache;

  @override
  Future<void> dispose() async {
    this._cache.clear();
  }
}
