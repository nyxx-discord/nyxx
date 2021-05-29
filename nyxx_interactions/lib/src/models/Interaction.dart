part of nyxx_interactions;

/// The Interaction data. e.g channel, guild and member
class Interaction extends SnowflakeEntity {
  /// Reference to bot instance.
  final Nyxx _client;

  /// The type of the interaction received.
  late final int type;

  /// The guild the command was sent in.
  late final Cacheable<Snowflake, Guild>? guild;

  /// The channel the command was sent in.
  late final Cacheable<Snowflake, TextChannel> channel;

  /// The member who sent the interaction
  late final Member memberAuthor;

  /// The user who sent the interaction.
  late final User userAuthor;

  /// Token to send requests
  late final String token;

  /// Version of interactions api
  late final int version;

  Interaction._new(this._client, Map<String, dynamic> raw) : super(Snowflake(raw["id"])) {
    this.type = raw["type"] as int;

    if (raw["guild_id"] != null) {
      this.guild = CacheUtility.createCacheableGuild(_client, Snowflake(raw["guild_id"]),);
    } else {
      this.guild = null;
    }

    this.channel = CacheUtility.createCacheableTextChannel(_client, Snowflake(raw["channel_id"]),);

    if (this.guild != null) {
      this.memberAuthor = EntityUtility.createGuildMember(_client, Snowflake(raw["guild_id"]), raw["member"] as Map<String, dynamic>,);
    } else {
      this.userAuthor = EntityUtility.createUser(_client, raw["user"] as Map<String, dynamic>);
    }

    this.token = raw["token"] as String;
    this.version = raw["version"] as int;
  }
}

/// Interaction for slash command
class SlashCommandInteraction extends Interaction {
  /// Name of interaction
  late final String name;

  /// Args of the interaction
  late final Iterable<InteractionOption> options;

  /// Id of command
  late final Snowflake commandId;

  SlashCommandInteraction._new(Nyxx client, Map<String, dynamic> raw) : super._new(client, raw) {
    this.name = raw["data"]["name"] as String;
    this.options = _generateArgs(raw["data"] as Map<String, dynamic>);
    this.commandId = Snowflake(raw["data"]["id"]);
  }

  /// Allows to fetch argument value by argument name
  dynamic? getArg(String name) {
    try {
      return this.options.firstWhere((element) => element.name == name);
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

abstract class ComponentInteraction implements Interaction {
  String get customId;
}

class ButtonInteraction extends Interaction implements ComponentInteraction {
  /// Id with additional custom metadata
  late final String customId;

  ButtonInteraction._new(Nyxx client, Map<String, dynamic> raw): super._new(client, raw) {
    this.customId = raw["data"]["custom_id"] as String;
  }
}

class DropdownInteraction extends Interaction implements ComponentInteraction {
  /// Id with additional custom metadata
  late final String customId;

  /// Values selected by the user
  late final List<String> values;

  DropdownInteraction._new(Nyxx client, Map<String, dynamic> raw): super._new(client, raw) {
    this.customId = raw["data"]["custom_id"] as String;
    this.values = (raw["data"]["values"] as List<dynamic>).cast<String>();
  }
}
