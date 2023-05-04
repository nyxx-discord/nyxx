/// An internal helper which parses [object] using [parse] if it is not null.
///
/// Prefer using this over a ternary (`raw['field'] == null ? null : parse(raw['field'])`).
T? maybeParse<T, U>(dynamic object, T Function(U) parse) {
  if (object == null) {
    return null;
  }

  if (object is! U) {
    throw FormatException('Unexpected type (expected $U)', object);
  }

  return parse(object);
}

/// An internal helper which parses each element of [objects] using [parse].
///
/// Prefer using this over an iterable map (`(raw['field'] as List).map(parse).toList()`) or a list literal
/// (`[for (final element in raw['field'] as List) parse(element)]`)
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

/// An internal helper which parses each element of [object] using [parse] if it is not null.
List<T>? maybeParseMany<T, U>(dynamic object, T Function(U) parse) => maybeParse<List<T>, List<dynamic>>(object, (object) => parseMany(object, parse));
