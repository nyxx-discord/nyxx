part of nyxx_interactions;

class Interaction extends SnowflakeEntity implements Disposable {
  /// Reference to bot instance
  final Nyxx client;

  late final int type;

  late final Cacheable<Snowflake, Guild> guild;

  late final Cacheable<Snowflake, TextChannel> channel;

  late final Member author;

  late final String token;

  late final int version;

  late final String name; // TODO

  late final Map<String, InteractionOption> args; // TODO

  Interaction._new(
      this.client,
      Map<String, dynamic> raw,
      ) : super(Snowflake(raw["id"])) {
    this.type = raw["type"] as int;

    this.guild = CacheUtility.createCacheableGuild(
      client,
      Snowflake(
        raw["guild_id"],
      ),
    );

    this.channel = CacheUtility.createCacheableTextChannel(
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

    this.name = raw["data"]["name"] as String;

    this.args = _generateArgs(raw["data"] as Map<String, dynamic>);
  }

  Map<String, InteractionOption> _generateArgs(Map<String, dynamic> rawData) {
    final args = <String, InteractionOption>{};

    if(rawData["options"] != null) {
      final l = rawData["options"] as List;
      for(var i = 0; i < l.length; i++) {
        final el = l[i];
        args[el["name"] as String] = InteractionOption._new(
          el["value"] as dynamic,
          (el["options"] ?? List<dynamic>.empty() ) as List,
        );
      }
    }

    return args;
  }

  @override
  Future<void> dispose() => Future.value(null);
}