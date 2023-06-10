/// An internal mixin containing a [toString] implementation when dart:mirrors is available.
///
/// Override [defaultToString] to change the output when dart:mirrors is not enabled.
mixin ToStringHelper {
  String defaultToString() => super.toString();

  @override
  String toString() => defaultToString();
}
