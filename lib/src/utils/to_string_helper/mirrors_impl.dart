import 'dart:mirrors';

/// An internal mixin containing a [toString] implementation when dart:mirrors is available.
mixin ToStringHelper {
  @override
  String toString() => stringifyInstance(reflect(this));
}

/// An internal function used when dart:mirrors is available to stringify the instance reflected by
/// [mirror].
String stringifyInstance(InstanceMirror mirror, [String? type]) {
  type ??= MirrorSystem.getName(mirror.type.simpleName);

  final buffer = StringBuffer('$type(\n');

  final getters = mirror.type.instanceMembers.values.where((member) => member.isGetter);
  const blockedGetters = [#manager, #hashCode, #runtimeType];

  final outputtedGetters = List.of(
    getters.where((getter) => !getter.isPrivate && !blockedGetters.contains(getter.simpleName)),
  );

  if (outputtedGetters.isEmpty) {
    return 'Instance of $type';
  }

  outputtedGetters.sort((a, b) {
    final aName = a.simpleName;
    final bName = b.simpleName;

    if (aName == #id) {
      return -1;
    }

    if (bName == #id) {
      return 1;
    }

    return aName.toString().compareTo(bName.toString());
  });

  for (final identifier in outputtedGetters.map((getter) => getter.simpleName)) {
    final value = mirror.getField(identifier);
    final String representation;

    // If the value has a custom `toString` implementation, call that. Otherwise recursively
    // stringify the value.
    if (value.type.instanceMembers[#toString]!.owner != reflectClass(Object)) {
      representation = value.reflectee.toString();
    } else {
      representation = stringifyInstance(value);
    }

    buffer.write('  ${MirrorSystem.getName(identifier)}: ');
    buffer.write(representation.replaceAll('\n', '\n  '));
    buffer.writeln(',');
  }

  buffer.write(')');
  return buffer.toString();
}
