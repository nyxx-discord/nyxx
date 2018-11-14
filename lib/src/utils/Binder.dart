import 'package:nyxx/nyxx.dart';
import 'Util.dart' as utils;

import 'dart:async';
import 'dart:mirrors';

/// Gets single annotation with type [T] from [declaration]
T getCmdAnnot<T>(DeclarationMirror declaration) {
  Iterable<T> fs = getCmdAnnots<T>(declaration);
  if (fs.isEmpty) return null;
  return fs.first;
}

/// Gets all annotations with type [T] from [declaration]
Iterable<T> getCmdAnnots<T>(DeclarationMirror declaration) sync* {
  for (var instance in declaration.metadata)
    if (instance.hasReflectee) {
      var reflectee = instance.reflectee;
      if (reflectee is T) yield reflectee;
    }
}

/// Binds all methods with [Bind] annotation to Client's streams.
void bindEvents(String libname, client) {
  var instanceThis = reflect(client);
  var classRefl = instanceThis.type;
  var lib = currentMirrorSystem().findLibrary(Symbol(libname));

  for (var decl in lib.declarations.values.whereType<MethodMirror>()) {
    var meta = getCmdAnnot<Bind>(decl);

    if (meta != null) {
      for (var incl
          in classRefl.declarations.values.whereType<VariableMirror>()) {
        if (meta.streamName == incl.simpleName.toString()) {
          instanceThis.getField(incl.simpleName).reflectee.listen((evnt) {
            Future.microtask(() => lib.invoke(decl.simpleName, [evnt]));
          });
        }
      }
    }
  }
}

/// Class used to bind method to Stream
class Bind {
  /// Name of stream to bind
  final String streamName;

  const Bind(String name) : streamName = "Symbol(\"$name\")";
}
