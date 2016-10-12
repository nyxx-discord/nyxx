part of discord;

/// A collection of objects, easily searchable.
class Collection<T> {
  /// The collection's internal map of objects.
  Map<String, T> map = <String, T>{};

  /// The list of objects in the collection.
  List<T> get list => this.map.values.toList();

  /// The size of the collection.
  int get size => this.map.length;

  /// The first element.
  T get first => this.list.first;

  /// The last element.
  T get last => this.list.last;

  /// Gets a item by it's key.
  T operator [](String key) => this.map[key];

  /// Adds a value to a collection.
  void add(dynamic value) {
    this.map[value._map['key']] = value as T;
  }

  /// Finds a single item where `item.property == value`.
  T find(String property, T value) {
    for (dynamic o in this.map.values) {
      if (o._map[property] == value) {
        return o as T;
      }
    }
    return null;
  }

  /// Finds a list of items where `item.property == value`.
  List<T> findAll(String property, T value) {
    List<T> matches = <T>[];
    for (dynamic o in this.map.values) {
      if (o._map[property] == value) {
        matches.add(o as T);
      }
    }
    return matches;
  }

  /// Applies the function `f` to each element of this collection in iteration order.
  void forEach(void f(T element)) {
    this.map.values.forEach(f);
  }
}
