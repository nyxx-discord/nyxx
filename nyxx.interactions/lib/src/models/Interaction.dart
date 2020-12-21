part of nyxx_interactions;

class Interaction extends SnowflakeEntity implements Disposable {
  /// Reference to bot instance
  final Nyxx client;

  late final int type;

  late final CommandInteractionData? data;

  late final Cacheable<Snowflake, Guild> guild;

  late final Cacheable<Snowflake, IChannel> channel;

  late final Member author;

  late final String token;

  late final int version;

  CommandInteractionData? _generateData(Map<String, dynamic> raw) {
    return raw["data"] != null
        ? CommandInteractionData._new(
            Snowflake(raw["data"]["id"]),
            raw["data"]["name"] as String,
            null, //TODO Add Tree Implimentation to show options
          )
        : null;
  }

  Interaction._new(
    this.client,
    Map<String, dynamic> raw,
  ) : super(Snowflake(raw["id"])) {
    this.type = raw["type"] as int;

    this.data = _generateData(
      raw,
    );

    this.guild = CacheUtility.createCacheableGuild(
      client,
      Snowflake(
        raw["guild_id"],
      ),
    );

    this.channel = CacheUtility.createCacheableChannel(
      client,
      Snowflake(
        raw["channel_id"],
      ),
    );

    this.author = EntityUtility.createGuildMember(
      client,
      Snowflake(
        raw["guild_id"],
      ),
      raw["member"] as Map<String, dynamic>,
    );

    this.token = raw["token"] as String;

    this.version = raw["version"] as int;
  }

  @override
  Future<void> dispose() => Future.value(null);
}
