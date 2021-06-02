part of nyxx;

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class Builder {
  /// Returns built response for api
  Map<String, dynamic> build();
}

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class BuilderWithClient {
  /// Returns built response for api
  Map<String, dynamic> build(INyxx client);
}
