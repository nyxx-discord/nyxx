part of nyxx;

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class Builder {
  /// Returns built response for api
  @meta.protected
  RawApiMap build();
}

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class BuilderWithClient {
  /// Returns built response for api
  @meta.protected
  RawApiMap build(INyxx client);
}
