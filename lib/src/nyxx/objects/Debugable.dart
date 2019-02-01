part of nyxx;

/// Due toString() is used to provide implicit functionality - [Debugable] returns human readable, debug object representation.
abstract class Debugable {
  /// Returns human readable, debug description of object
  String get debugString;
}
