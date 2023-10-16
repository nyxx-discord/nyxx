import 'dart:mirrors';

import 'package:nyxx/src/http/managers/manager.dart';
import 'package:runtime_type/mirrors.dart';
import 'package:runtime_type/runtime_type.dart';

/// An internal mixin containing a [toString] implementation when dart:mirrors is available.
///
/// Override [defaultToString] to change the output when dart:mirrors is not enabled.
mixin ToStringHelper {
  /// Same as [toString], but only called when dart:mirrors is not available.
  ///
  /// If dart:mirrors is available, it will be used to print a complete representation of this object.
  String defaultToString() => super.toString();

  @override
  String toString() => stringifyInstance(reflect(this));
}

final _stringifyStack = <Object?>[];

/// An internal function used when dart:mirrors is available to stringify the instance reflected by
/// [mirror].
String stringifyInstance(InstanceMirror mirror) {
  final existingIndex = _stringifyStack.indexOf(mirror.reflectee);
  if (existingIndex >= 0) {
    return '<Recursive #$existingIndex>';
  }
  _stringifyStack.add(mirror.reflectee);

  final type = MirrorSystem.getName(mirror.type.simpleName);

  final buffer = StringBuffer('$type(\n');

  final getters = mirror.type.instanceMembers.values.where((member) => member.isGetter);
  const blockedGetters = [#manager, #hashCode, #runtimeType];

  final outputtedGetters = List.of(
    getters.where(
      (getter) =>
          !getter.isPrivate && !blockedGetters.contains(getter.simpleName) && !getter.returnType.toRuntimeType().isSubtypeOf(RuntimeType<ReadOnlyManager>()),
    ),
  );

  if (outputtedGetters.isEmpty) {
    _stringifyStack.removeLast();
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
    late final String representation;
    try {
      representation = mirror.getField(identifier).reflectee.toString();
    } catch (e) {
      representation = '<$e>';
    }

    buffer.write('  ${MirrorSystem.getName(identifier)}: ');
    buffer.write(representation.replaceAll('\n', '\n  '));
    buffer.writeln(',');
  }

  buffer.write(')');
  _stringifyStack.removeLast();
  return buffer.toString();
}
