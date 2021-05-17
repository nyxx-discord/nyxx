part of nyxx;

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class Builder {
  Map<String, dynamic> _build();
}

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class BuilderWithClient {
  Map<String, dynamic> build(INyxx client);
}
