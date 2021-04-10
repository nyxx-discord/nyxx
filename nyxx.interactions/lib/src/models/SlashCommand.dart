part of nyxx_interactions;

/// A slash command, can only be instantiated through a method on [Interactions]
class SlashCommand {
  final Nyxx _client;

  Snowflake? _id;

  Snowflake get id {
    if (!this.isRegistered || _id == null) {
      throw new StateError("There is no id if command is not registered");
    }

    return _id!;
  }

  /// Command name to be shown to the user in the Slash Command UI
  final String name;

  /// Command description shown to the user in the Slash Command UI
  final String description;

  /// The guild that the slash Command is registered in. This can be null if its a global command.
  late final Cacheable<Snowflake, Guild>? guild;

  /// The arguments that the command takes
  final List<CommandArg> args;

  /// If the command is a global on, false if restricted to a guild.
  bool get isGlobal => this.guild == null;

  /// If the command has been registered with the discord api
  late bool isRegistered = false;

  SlashCommand._new(this._client, this.name, this.description, this.args, {this.guild});

  Future<SlashCommand> _register() async {
    final options = args.map((e) => e._build()).toList();

    var path = "/applications/${this._client.app.id.toString()}";

    if (this.guild != null) {
      path += "/guilds/${this.guild!.id}";
    }

    path += "/commands";

    final response = await this._client.httpEndpoints.sendRawRequest(
      path,
      "POST",
      body: {"name": this.name, "description": this.description, "options": options.isNotEmpty ? options : null},
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    this._id = Snowflake((response as HttpResponseSuccess).jsonBody["id"]);
    this.isRegistered = true;
    return this;
  }
}
