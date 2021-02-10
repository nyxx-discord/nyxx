part of nyxx_interactions;

/// The Interaction data. e.g channel, guild and member
class Interaction extends SnowflakeEntity implements Disposable {
  /// Reference to bot instance.
  final Nyxx _client;

  /// The type of the interaction received.
  late final int type;

  /// The guild the command was sent in.
  late final Cacheable<Snowflake, Guild> guild;

  /// The channel the command was sent in.
  late final Cacheable<Snowflake, TextChannel> channel;

  /// The member who sent the interaction
  late final Member author;

  /// Token to send requests
  late final String token;

  /// Version of interactions api
  late final int version;

  /// Name of interaction
  late final String name;

  /// Args of the interaction
  late final Map<String, InteractionOption> args;

  Interaction._new(
    this._client,
    Map<String, dynamic> raw,
  ) : super(Snowflake(raw["id"])) {
    this.type = raw["type"] as int;
    this.guild = CacheUtility.createCacheableGuild(
      _client,
      Snowflake(
        raw["guild_id"],
      ),
    );
    this.channel = CacheUtility.createCacheableTextChannel(
      _client,
      Snowflake(
        raw["channel_id"],
      ),
    );
    this.author = EntityUtility.createGuildMember(
      _client,
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

    if (rawData["options"] != null) {
      final l = rawData["options"] as List;
      for (var i = 0; i < l.length; i++) {
        final el = l[i];
        args[el["name"] as String] = InteractionOption._new(
          el["value"] as dynamic,
          (el["options"] ?? List<dynamic>.empty()) as List,
        );
      }
    }

    return args;
  }

  @override
  Future<void> dispose() => Future.value(null);
}
