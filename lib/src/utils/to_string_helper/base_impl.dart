/// An internal mixin containing a [toString] implementation when dart:mirrors is available.
///
/// Override [defaultToString] to change the output when dart:mirrors is not enabled.
mixin ToStringHelper {
  /// Same as [toString], but only called when dart:mirrors is not available.
  ///
  /// If dart:mirrors is available, it will be used to print a complete representation of this object.
  String defaultToString() => super.toString();

  @override
  String toString() => defaultToString();
}
