part of nyxx;

/// Cache for messages. Provides few utilities methods to facilitate interaction with messages.
/// []= operator throws - use put() instead.
class MessageCache extends Cache<Snowflake, Message> {
  final int _size;

  MessageCache._new(this._size) {
    this._cache = {};
  }

  /// Caches message
  Message _cacheMessage(Message message) {
    if (this._size > 0) {
      if (this._cache.length >= this._size) {
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
  Iterable<Message> get byBot => values.where((m) => m.author is User && (m.author as User).bot);

  /// Returns messages in chronological order
  List<Message> get inOrder => _cache.values.toList()..sort((f, s) => f.createdAt.compareTo(s.createdAt));

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
  void operator []=(Snowflake key, Message item) =>
      throw UnsupportedError("Unsupported operation. Use put() instead");
}
