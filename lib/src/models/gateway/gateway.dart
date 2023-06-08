import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template gateway_configuration}
/// Information about how to connect to the Gateway.
/// {@endtemplate}
class GatewayConfiguration with ToStringHelper {
  /// The URL to connect to.
  final Uri url;

  /// {@macro gateway_configuration}
  GatewayConfiguration({required this.url});
}

/// {@template gateway_bot}
/// Information about how to connect to the Gateway, with client-specific information.
/// {@endtemplate}
class GatewayBot extends GatewayConfiguration {
  /// The recommended number of shards to use.
  final int shards;

  /// Information about the client's session start limits.
  final SessionStartLimit sessionStartLimit;

  /// {@macro gateway_bot}
  GatewayBot({
    required super.url,
    required this.shards,
    required this.sessionStartLimit,
  });
}

/// {@template session_start_limit}
/// Information about a client's session start limits.
/// {@endtemplate}
class SessionStartLimit with ToStringHelper {
  /// The total number of sessions that can be opened.
  final int total;

  /// The current number of sessions that have been opened.
  final int remaining;

  /// The time after which [remaining] will reset.
  final Duration resetAfter;

  /// The maximum number of concurrent shards identifying.
  final int maxConcurrency;

  /// {@macro session_start_limit}
  SessionStartLimit({
    required this.total,
    required this.remaining,
    required this.resetAfter,
    required this.maxConcurrency,
  });
}
