import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class GatewayConfiguration with ToStringHelper {
  final Uri url;

  GatewayConfiguration({required this.url});
}

class GatewayBot extends GatewayConfiguration {
  final int shards;

  final SessionStartLimit sessionStartLimit;

  GatewayBot({
    required super.url,
    required this.shards,
    required this.sessionStartLimit,
  });
}

class SessionStartLimit with ToStringHelper {
  final int total;

  final int remaining;

  final Duration resetAfter;

  final int maxConcurrency;

  SessionStartLimit({
    required this.total,
    required this.remaining,
    required this.resetAfter,
    required this.maxConcurrency,
  });
}
