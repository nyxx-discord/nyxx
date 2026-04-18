import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/utils/to_string_helper/mirrors_impl.dart';

/// An event emitted when a Gateway request encounters a rate limit.
///
/// {@category events}
class RateLimitedEvent<T extends RateLimitedMetadata> extends DispatchEvent {
  /// The opcode of the request that was rate limited.
  final Opcode rateLimitedOpcode;

  /// The duration after which the request should be retried.
  final Duration retryAfter;

  /// Additional information about the rate limit, depending on the type of the request.
  final T meta;

  /// @nodoc
  RateLimitedEvent({required this.rateLimitedOpcode, required this.retryAfter, required this.meta, required super.gateway});
}

/// Additional information about a rate limited Gateway request.
abstract class RateLimitedMetadata with ToStringHelper {}

/// Unparsed information about a rate limited Gateway request.
///
/// {@category models}
class UnknownRateLimitedMetadata extends RateLimitedMetadata {
  final Map<String, Object?> raw;

  /// @nodoc
  UnknownRateLimitedMetadata({required this.raw});
}

/// Additional information about a rate limited [Opcode.requestGuildMembers] Gateway request.
///
/// {@category models}
class RequestGuildMemberRateLimitedMetadata extends RateLimitedMetadata {
  /// The [Gateway] instance that created this metadata.
  final Gateway gateway;

  /// The ID of the guild that the request was for.
  final Snowflake guildId;

  /// The nonce of the request.
  final String? nonce;

  /// @nodoc
  RequestGuildMemberRateLimitedMetadata({required this.guildId, required this.nonce, required this.gateway});

  /// The guild that the request was for.
  PartialGuild get guild => gateway.client.guilds[guildId];
}
