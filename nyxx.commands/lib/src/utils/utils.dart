part of nyxx.commands;

class Utils {
  /// Gets [Symbol]s 'name'
  static String _getSymbolName(Symbol symbol) {
    return RegExp('Symbol\(\"(.+)\"\)')
        .matchAsPrefix(symbol.toString())
        .group(1);
  }

  /// Gets single annotation with type [T] from [declaration]
  static T? _getCmdAnnot<T>(DeclarationMirror declaration) {
    Iterable<T> fs = _getCmdAnnots<T>(declaration);
    if (fs.isEmpty) return null;
    return fs.first;
  }

  /// Gets all annotations with type [T] from [declaration]
  static Iterable<T> _getCmdAnnots<T>(DeclarationMirror declaration) sync* {
    for (var instance in declaration.metadata)
      if (instance.hasReflectee && instance.reflectee is T)
        yield instance.reflectee as T;
  }
}
