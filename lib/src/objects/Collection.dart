/// A collection of objects, easily searchable.
class Collection {
  /// The collection's internal map of objects.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The list of objects in the collection.
  List<dynamic> get list => this.map.values.toList();

  /// The size of the collection.
  int get size => this.map.length;

  /// The first element.
  dynamic get first => this.list.first;

  /// The last element.
  dynamic get last => this.list.last;

  /// Gets a item by ID.
  dynamic get(String key) {
    return this.map[key];
  }

  /// Adds a value to a collection.
  void add(dynamic value) {
    this.map[value.id] = value;
  }

  /// Finds a single item where `item.property == value`.
  dynamic find(String property, dynamic value) {
    for (dynamic o in this.map.values) {
      if (o.map[property] == value) {
        return o;
      }
    }
    return null;
  }

  /// Finds a list of items where `item.property == value`.
  List<dynamic> findAll(String property, dynamic value) {
    List<dynamic> matches = <dynamic>[];
    for (dynamic o in this.map.values) {
      if (o.map[property] == value) {
        matches.add(o);
      }
    }
    return matches;
  }

  /// Applies the function `f` to each element of this collection in iteration order.
  void forEach(void f(dynamic element)) {
    this.map.values.forEach(f);
  }
}
