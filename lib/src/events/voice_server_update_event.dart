import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IVoiceServerUpdateEvent {
  /// Raw websocket event payload
  RawApiMap get raw;

  /// Voice connection token
  String get token;

  /// The voice server host
  String get endpoint;

  /// The guild this voice server update is for
  Cacheable<Snowflake, IGuild> get guild;
}

/// Emitted when guild's voice server changes
class VoiceServerUpdateEvent implements IVoiceServerUpdateEvent {
  /// Raw websocket event payload
  @override
  final RawApiMap raw;

  /// Voice connection token
  @override
  late final String token;

  /// The voice server host
  @override
  late final String endpoint;

  /// The guild this voice server update is for
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [VoiceServerUpdateEvent]
  VoiceServerUpdateEvent(this.raw, INyxx client) {
    token = raw["d"]["token"] as String;
    endpoint = raw["d"]["endpoint"] as String;
    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
  }
}
