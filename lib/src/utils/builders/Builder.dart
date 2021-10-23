import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class Builder {
  /// Returns built response for api
  RawApiMap build();
}

/// Provides abstraction for builders
// ignore: one_member_abstracts
abstract class BuilderWithClient {
  /// Returns built response for api
  RawApiMap build(INyxx client);
}
