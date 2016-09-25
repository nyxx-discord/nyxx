class Collection {
  /// The collection's internal map of objects.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The list of objects in the collection.
  List<dynamic> get list => this.map.values.toList();

  /// Gets a item by ID.
  dynamic get(String key) {
    return this.map[key];
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
}
