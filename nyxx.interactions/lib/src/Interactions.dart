part of nyxx_interactions;

/// Interaction extension for Nyxx. Allows use of: Slash Commands.
class Interactions {
  late final Nyxx _client;
  final Logger _logger = Logger("Interactions");
  late final _EventController _events;

  /// Emitted when a a slash command is sent.
  late Stream<InteractionEvent> onSlashCommand;

  ///
  Interactions(Nyxx client) {
    client.options.dispatchRawShardEvent = true;
    this._client = client;
    _events = _EventController(this);
    client.onReady.listen((event) {
      client.shardManager.rawEvent.listen((event) {
        print(event);
        if (event.rawData["op"] as int == 0) {
          if (event.rawData["t"] as String == "INTERACTION_CREATE") {
            _events.onSlashCommand.add(
              InteractionEvent._new(
                  client, event.rawData["d"] as Map<String, dynamic>),
            );
          }
        }
      });
      _logger.info("Interactions ready");
    });
  }

  Future<SlashCommand> registerSlashGlobal(
      String name, String description, List<SlashArg> args) async {
    final command =
        SlashCommand._new(this._client, name, args, description, null);
    final response = await this._client.httpEndpoints.sendRawRequest(
          "/applications/${this._client.app.id.toString()}/commands",
          "POST",
          body: command._build(),
        );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return Future.value(command);
  }

  Future<SlashCommand> registerSlashGuild(String name, String description,
      Snowflake guildId, List<SlashArg> args) async {
    final command =
        SlashCommand._new(this._client, name, args, description, guildId);
    command._build();
    final response = await this._client.httpEndpoints.sendRawRequest(
          "/applications/${this._client.app.id.toString()}/guilds/${guildId.toString()}/commands",
          "POST",
          body: command._build(),
        );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return Future.value(command);
  }
}
