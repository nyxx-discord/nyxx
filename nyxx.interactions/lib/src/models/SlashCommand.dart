part of nyxx_interactions;

/// A slash command, can only be instantiated through a method on [Interactions]
class SlashCommand {
  /// Command name to be shown to the user in the Slash Command UI
  late final String name;
  /// Command description shown to the user in the Slash Command UI
  late final String description;
  /// The guild that the slash Command is registered in. This can be null if its a global command.
  late final Cacheable<Snowflake, Guild>? guild;
  /// The arguments that the command takes
  late final List<CommandArg> args;
  /// If the command is a global on, false if restricted to a guild.
  late final bool isGlobal;
  /// If the command has been registered with the discord api
  late bool isRegistered = false;

  late final Nyxx _client;

  SlashCommand._new(this._client, this.name, this.description, this.args, {this.guild}) {
    this.isGlobal = guild == null;
  }

  Future<SlashCommand> _register() async {
    final options = args.map((e) => e._build());

    final response = await this._client.httpEndpoints.sendRawRequest(
      "/applications/${this._client.app.id.toString()}/commands",
      "POST",
      body: {"name": this.name, "description": this.description, "options": options.isNotEmpty ? options : null},
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    this.isRegistered = true;
    return this;
  }
}
