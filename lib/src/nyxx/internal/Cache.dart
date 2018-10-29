part of nyxx;

/// Generic interface for caching entities.
/// Wraps [Map] interface and provides utilities for manipulating cache.
abstract class Cache<T, S> implements Disposable {
  Map<T, S> _cache;

  /// Returns values of cache
  Iterable<S> get values => _cache.values;

  /// Returns key's values of cache
  Iterable<T> get keys => _cache.keys;

  /// Find one element in cache
  S findOne(bool f(S item)) => values.firstWhere(f);
  Iterable<S> find(bool f(S item)) => values.where(f);

  /// Returns Map of keys and values where values are of type [G]
  Map<T, G> whereType<G>() {
    var tmp = Map<T, G>();
    _cache.forEach((k, v) {
      if(v is G) tmp[k] = v;
    });
    return tmp;
  }

  /// Returns element with key [key]
  S operator [](T key) => _cache[key];

  /// Sets [value] for [key]
  void operator []=(T key, S item) => _cache[key] = item;

  /// Puts element to collection if [key] doesn't exist in cache
  S addIfAbsent(T key, S item)  {
    if(!_cache.containsKey(T))
      return _cache[key] = item;
    return _cache[key];
  }

  /// Returns true if cache contains [key]
  bool hasKey(T key) => _cache.containsKey(key);

  /// Returns true if cache contains [value]
  bool hasValue(S value) => _cache.containsValue(value);

  /// Clear cache
  void invalidate() => _cache.clear();

  /// Add to cache [value] associated with [key]
  void add(T key, S value) => _cache[key] = value;

  /// Combines [keys] with [values] - First elements with [keys] creates pair with first value from [values]
  /// Collection have to be same length
  void addMany(List<T> keys, List<S> values) {
    if(keys.length != values.length)
      throw new Exception("Cannot combine Iterables with different length!");

    for(var i = 0; i < keys.length; i++) {
      _cache[keys[i]] = values[i];
    }
  }

  /// Add [Map] to cache.
  void addMap(Map<T, S> mp) => _cache.addAll(mp);

  /// Remove [key] with associated with it value
  void remove(T key) => _cache.remove(key);

  /// Remove everything where [predicate] is true
  void removeWhere(bool predicate(T key, S value)) => _cache.removeWhere(predicate);

  /// Loop over elements from cache
  void forEach(void f(T key, S value)) => _cache.forEach(f);

  /// Take [count] elements from cache. Returns Iterable of cache values
  Iterable<S> take(int count) => values.take(count);

  /// Takes [count] last elements from cache. Returns Iterable of cache values
  Iterable<S> takeLast(int count) => values.toList().sublist(values.length - count);

  /// Get first element
  S get first => _cache.values.first;

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
    if(T is Disposable) {
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
  Future<Function> dispose() => Future(() {
    _cache.forEach((_, v) {
      if(v is MessageChannel)
        v.dispose();
    });

    _cache.clear();
  });

}

/// Cache for messages. Provides few utilities methods to facilitate interaction with messages.
/// []= operator throws - use put() instead.
class MessageCache extends Cache<Snowflake, Message> {
  MessageCache._new() {
    this._cache = LinkedHashMap();
  }

  /// Caches message
  Message _cacheMessage(Message message) {
    if (_client._options.messageCacheSize > 0) {
      if (this._cache.length >= _client._options.messageCacheSize) {
        this._cache.remove(this._cache.values.last.id);
      }
      this._cache[message.id] = message;
    }

    return message;
  }

  /// Allows to put message into cache
  Message put(Message message) => _cacheMessage(message);

  /// Returns messages which were sent by [user]
  Iterable<Message> fromUser(User user) => values.where((m) => m.author == user);

  /// Returns messages which were sent by [users]
  Iterable<Message> fromUsers(Iterable<User> users) => values.where((m) => users.contains(m.author));

  /// Returns messages which were created before [date]
  Iterable<Message> beforeDate(DateTime date) => values.where((m) => m.createdAt.isBefore(date));

  /// Returns messages which were created before [date]
  Iterable<Message> afterDate(DateTime date) => values.where((m) => m.createdAt.isAfter(date));

  /// Returns messages which were sent by bots
  Iterable<Message> get byBot => values.where((m) => m.author.bot);

  @override
  /// Takes first [count] elements from cache. Returns Iterable of cache values
  Iterable<Message> take(int count) => values.toList().sublist(values.length - count);

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
  void operator []=(Snowflake key, Message item) {
    throw new Exception("Dont do this. Use put() instead!");
  }
}

/// Cache which is cleaned up.
class VoltCache<T, S> extends Cache<T, S> {
  VoltCache(Duration duration, bool roundup(T key, S value, Timer t)) {
    _cache = Map();

    Timer.periodic(duration, (t) {
      _cache.forEach((k, v) {
        if(roundup(k, v, t))
          _cache.remove(k);
      });
    });
  }
}