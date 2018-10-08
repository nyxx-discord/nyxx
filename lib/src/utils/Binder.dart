import 'package:nyxx/nyxx.dart';
import 'Util.dart' as utils;

import 'dart:async';
import 'dart:mirrors';

void bindEvents(String libname) {
  var instanceThis = reflect(client);
  var classRefl = instanceThis.type;
  var lib = currentMirrorSystem().findLibrary(Symbol(libname));

  for(var decl in lib.declarations.values.whereType<MethodMirror>()) {
    var meta = utils.getCmdAnnot<Bind>(decl);

    if(meta != null) {
      for(var incl in classRefl.declarations.values.whereType<VariableMirror>()) {
        if(meta.streamName == incl.simpleName.toString()) {
          instanceThis.getField(incl.simpleName).reflectee.listen((evnt) {
            Future.microtask(() => lib.invoke(decl.simpleName, [evnt]));
          });
        }
      }
    }
  }
}

class Bind {
  final String streamName;
  const Bind(String name): streamName = "Symbol(\"$name\")";
}