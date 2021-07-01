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

  Interaction._new(this._client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    this.type = raw["type"] as int;

    if (raw["guild_id"] != null) {
      this.guild = CacheUtility.createCacheableGuild(_client, Snowflake(raw["guild_id"]),);
    } else {
      this.guild = null;
    }

    this.channel = CacheUtility.createCacheableTextChannel(_client, Snowflake(raw["channel_id"]),);

    if (this.guild != null) {
      this.memberAuthor = EntityUtility.createGuildMember(_client, Snowflake(raw["guild_id"]), raw["member"] as RawApiMap,);
    } else {
      this.userAuthor = EntityUtility.createUser(_client, raw["user"] as RawApiMap);
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

  SlashCommandInteraction._new(Nyxx client, RawApiMap raw) : super._new(client, raw) {
    this.name = raw["data"]["name"] as String;
    this.options = _generateArgs(raw["data"] as RawApiMap);
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

  Iterable<InteractionOption> _generateArgs(RawApiMap rawData) sync* {
    if (rawData["options"] == null) {
      return;
    }

    final options = rawData["options"] as List<dynamic>;
    for (final option in options) {
      yield InteractionOption._new(option as RawApiMap);
    }
  }
}

/// Interaction for button, dropdown, etc.
abstract class ComponentInteraction extends Interaction {
  /// Custom id of component interaction
  String get customId;

  /// The message that the button was pressed on.
  late final Message message;

  ComponentInteraction._new(Nyxx client, RawApiMap raw): super._new(client, raw) {
    // Discord doesn't include guild's id in the message object even if its a guild message but is included in the data so its been added to the object so that guild message can be used if the interaction is from a guild.
    this.message = EntityUtility.createMessage(this._client, {...raw["message"] as RawApiMap, if(raw["guild_id"] != null) "guild_id": raw["guild_id"]});
  }
}

class ButtonInteraction extends ComponentInteraction {
  @override
  late final String customId;

  ButtonInteraction._new(Nyxx client, Map<String, dynamic> raw): super._new(client, raw) {
    this.customId = raw["data"]["custom_id"] as String;
  }
}

class MultiselectInteraction extends ComponentInteraction {
  @override
  late final String customId;

  /// Values selected by the user
  late final List<String> values;

  MultiselectInteraction._new(Nyxx client, Map<String, dynamic> raw): super._new(client, raw) {
    this.customId = raw["data"]["custom_id"] as String;
    this.values = (raw["data"]["values"] as List<dynamic>).cast<String>();
  }
}
