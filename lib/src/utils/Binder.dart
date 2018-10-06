import 'package:nyxx/nyxx.dart';
import 'Util.dart' as utils;

import 'dart:async';
import 'dart:mirrors';

void bindEvents() {
  var instanceThis = reflect(client);
  var classRefl = instanceThis.type;

  for(var lib in currentMirrorSystem().libraries.values) {
    for(var decl in lib.declarations.values.whereType<MethodMirror>()) {
      var meta = utils.getCmdAnnot<Bind>(decl);

      if(meta != null) {
        for(var incl in classRefl.declarations.values.whereType<VariableMirror>()) {
          if(meta.streamName == incl.simpleName) {
            print("REGISTERED HANDLER: ${decl.simpleName}");
            instanceThis.getField(incl.simpleName).reflectee.listen((evnt) {
              Future.microtask(() => lib.invoke(decl.simpleName, [evnt]));
            });
          }
        }
      }
    }
  }
}

class Bind {
  final Symbol streamName;

  const Bind(this.streamName);
}