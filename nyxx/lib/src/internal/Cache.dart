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
  S? findOne(bool predicate(S item)) =>
      values.firstWhere(predicate, orElse: () => null);

  /// Find matching items based of [predicate]
  Iterable<S> find(bool predicate(S item)) => values.where(predicate);

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
  void removeWhere(bool predicate(T key, S value)) =>
      _cache.removeWhere(predicate);

  /// Loop over elements from cache
  void forEach(void f(T key, S value)) => _cache.forEach(f);

  /// Take [count] elements from cache. Returns Iterable of cache values
  Iterable<S> take(int count) => values.take(count);

  /// Takes [count] last elements from cache. Returns Iterable of cache values
  Iterable<S> takeLast(int count) =>
      values.toList().sublist(values.length - count);

  /// Get first element
  S? get first => _cache.values.first;

  /// Get last element
  S get last => _cache.values.last;

  /// Get number of elements from cache
  int get count => _cache.length;

  /// Returns cache as Map
  Map<T, S> get asMap => this._cache;

  @override
  Future<void> dispose() => Future(() {
        this._cache.clear();
      });
}

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

/// Cache for Channels
class ChannelCache extends Cache<Snowflake, Channel> {
  ChannelCache._new() {
    this._cache = Map();
  }

  /// Allows to get channel and cast to [E] in one operation.
  E get<E>(Snowflake id) => _cache[id] as E;

  @override
  Future<void> dispose() => Future(() {
        _cache.forEach((_, v) {
          if (v is MessageChannel) v.dispose();
        });

        _cache.clear();
      });
}

/// Cache for messages. Provides few utilities methods to facilitate interaction with messages.
/// []= operator throws - use put() instead.
class MessageCache extends Cache<Snowflake, Message> {
  ClientOptions _options;

  MessageCache._new(this._options) {
    this._cache = LinkedHashMap();
  }

  /// Caches message
  Message _cacheMessage(Message message) {
    if (_options.messageCacheSize > 0) {
      if (this._cache.length >= _options.messageCacheSize) {
        this._cache.remove(this._cache.values.last.id);
      }
      this._cache[message.id] = message;
    }

    return message;
  }

  /// Allows to put message into cache
  Message put(Message message) => _cacheMessage(message);

  /// Returns messages which were sent by [user]
  Iterable<Message> fromUser(User user) =>
      values.where((m) => m.author == user);

  /// Returns messages which were sent by [users]
  Iterable<Message> fromUsers(Iterable<User> users) =>
      values.where((m) => users.contains(m.author));

  /// Returns messages which were created before [date]
  Iterable<Message> beforeDate(DateTime date) =>
      values.where((m) => m.createdAt.isBefore(date));

  /// Returns messages which were created before [date]
  Iterable<Message> afterDate(DateTime date) =>
      values.where((m) => m.createdAt.isAfter(date));

  /// Returns messages which were sent by bots
  Iterable<Message> get byBot => values.where((m) => m.author.bot);

  /// Returns messages in chronological order
  List<Message> get inOrder => _cache.values.toList()
    ..sort((f, s) => f.createdAt.compareTo(s.createdAt));

  @override

  /// Takes first [count] elements from cache. Returns Iterable of cache values
  Iterable<Message> take(int count) =>
      values.toList().sublist(values.length - count);

  @override

  /// Takes last [count] elements from cache. Returns Iterable of cache values
  Iterable<Message> takeLast(int count) => values.take(count);

  /// Get first element
  @override
  Message get first => _cache.values.last;

  /// Get last element
  @override
  Message get last => _cache.values.first;

  /// Unsupported
  @override
  void operator []=(Snowflake key, Message item) =>
      throw new UnsupportedError("Unsupported operation. Use put() instead");
}
