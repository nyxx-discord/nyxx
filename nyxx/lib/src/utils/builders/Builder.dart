part of nyxx;

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class Builder {
  Map<String, dynamic> _build();

  // ignore: public_member_api_docs
  Map<String, dynamic> build() => _build();
}

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class BuilderWithClient {
  Map<String, dynamic> _build(INyxx client);

  // ignore: public_member_api_docs
  Map<String, dynamic> build(INyxx client) => _build(client);
}
