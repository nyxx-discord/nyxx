part of nyxx_interactions;

/// The Interaction data. e.g channel, guild and member
class Interaction extends SnowflakeEntity {
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
  late final Iterable<InteractionOption> args;

  /// Id of command
  late final Snowflake commandId;

  Interaction._new(this._client, Map<String, dynamic> raw) : super(Snowflake(raw["id"])) {
    this.type = raw["type"] as int;

    this.guild = CacheUtility.createCacheableGuild(
      _client,
      Snowflake(raw["guild_id"],),
    );

    this.channel = CacheUtility.createCacheableTextChannel(
      _client,
      Snowflake(raw["channel_id"]),
    );

    this.author = EntityUtility.createGuildMember(
      _client,
      Snowflake(raw["guild_id"]),
      raw["member"] as Map<String, dynamic>,
    );

    this.token = raw["token"] as String;
    this.version = raw["version"] as int;
    this.name = raw["data"]["name"] as String;
    this.args = _generateArgs(raw["data"] as Map<String, dynamic>);
    this.commandId = Snowflake(raw["data"]["id"]);
  }

  /// Allows to fetch argument value by argument name
  dynamic? getArg(String name) {
    try {
      return this.args.firstWhere((element) => element.name == name);
    } on Error {
      return null;
    }
  }

  Iterable<InteractionOption> _generateArgs(Map<String, dynamic> rawData) sync* {
    if (rawData["options"] == null) {
      return;
    }

    final options = rawData["options"] as List<dynamic>;
    for (final option in options) {
      yield InteractionOption._new(option as Map<String, dynamic>);
    }
  }
}
