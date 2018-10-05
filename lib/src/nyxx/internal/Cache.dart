part of nyxx;

abstract class Cache<T, S> {
  Map<T, S> _cache;

  Iterable<S> get values => _cache.values;
  Iterable<T> get keys => _cache.keys;

  S findOne(bool f(S item)) => values.firstWhere(f);
  Iterable<S> find(bool f(S item)) => values.where(f);

  Map<T, G> whereType<G>() {
    var tmp = Map<T, G>();
    
    _cache.forEach((k, v) {
      if(v is G)
        tmp[k] = v;
    });

    return tmp;
  }

  S operator [](T key) => _cache[key];
  void operator []=(T key, S item) => _cache[key] = item;

  S putIfAbsent(T key, S item)  {
    if(!_cache.containsKey(T))
      return _cache[key] = item;
    return _cache[key];
  }

  bool hasKey(T key) => _cache.containsKey(key);
  bool hasValue(S value) => _cache.containsValue(value);

  void invalidate() => _cache.clear();
  void add(T key, S value) => _cache[key] = value;
  void addMany(List<T> keys, List<S> values) {
    if(keys.length != values.length)
      throw new Exception("Cannot combine Iterables with different length!");

    for(var i = 0; i < keys.length; i++) {
      _cache[keys[i]] = values[i];
    }
  }

  void addMap(Map<T, S> mp) => _cache.addAll(mp);

  void remove(T key) => _cache.remove(key);
  void removeWhere(bool predicate(T key, S value)) => _cache.removeWhere(predicate);
  void forEach(void f(T key, S value)) => _cache.forEach(f);

  Iterable<S> take(int count) => values.take(count);
  Iterable<S> takeLast(int count) => values.toList().sublist(values.length - count);

  int get count => _cache.length;

  Map<T, S> get asMap => this._cache;
}

class _SnowflakeCache<T> extends Cache<Snowflake, T> {
  _SnowflakeCache() {
    this._cache = Map();
  }
}

abstract class IChannelCache implements Cache<Snowflake, Channel> {
  E get<E>(Snowflake id);
}

class _ChannelCache extends Cache<Snowflake, Channel> implements IChannelCache {
  _ChannelCache() {
    this._cache = Map();
  }

  @override
  E get<E>(Snowflake id) => _cache[id] as E;
}


abstract class IMessageCache implements Cache<Snowflake, Message> {
  Message _cacheMessage(Message message);
  Message put(Message message);
  Iterable<Message> fromUser(User user);
  Iterable<Message> fromUsers(Iterable<User> users);
  Iterable<Message> beforeDate(DateTime date);
  Iterable<Message> afterDate(DateTime date);
  Iterable<Message> get byBot;
}

class _MessageCache extends Cache<Snowflake, Message> implements IMessageCache {
  _MessageCache() {
    this._cache = LinkedHashMap();
  }

  @override
  Message _cacheMessage(Message message) {
    if (_client._options.messageCacheSize > 0) {
      if (this._cache.length >= _client._options.messageCacheSize) {
        this._cache.values.first._onUpdate.close();
        this._cache.values.first._onDelete.close();
        this._cache.remove(this._cache.values.first.id);
      }
      this._cache[message.id] = message;
    }

    return message;
  }

  @override
  Message put(Message message) => _cacheMessage(message);

  @override
  Iterable<Message> fromUser(User user) => values.where((m) => m.author == user);

  @override
  Iterable<Message> fromUsers(Iterable<User> users) => values.where((m) => users.contains(m.author));

  @override
  Iterable<Message> beforeDate(DateTime date) => values.where((m) => m.createdAt.isBefore(date));

  @override
  Iterable<Message> afterDate(DateTime date) => values.where((m) => m.createdAt.isAfter(date));

  @override
  Iterable<Message> get byBot => values.where((m) => m.author.bot);

  @override
  void operator []=(Snowflake key, Message item) {
    throw new Exception("Dont do this. Use put() instead!");
  }
}