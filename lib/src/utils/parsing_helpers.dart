T? maybeParse<T, U>(dynamic object, T Function(U) parse) {
  if (object == null) {
    return null;
  }

  if (object is! U) {
    throw FormatException('Unexpected type (expected $U)', object);
  }

  return parse(object);
}

List<T> parseMany<T, U>(List<dynamic> objects, T Function(U) parse) {
  return List.generate(
    objects.length,
    (index) {
      final raw = objects[index];

      if (raw is! U) {
        throw FormatException('Unexpected type (expected $U)', raw);
      }

      return parse(raw);
    },
  );
}
