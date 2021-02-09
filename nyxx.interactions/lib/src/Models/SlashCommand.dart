part of nyxx_interactions;

class SlashCommand {

  late final String name;
  late final String description;
  late final Cacheable<Snowflake, Guild>? guild;
  late final List<CommandArg> args;
  late final bool isGlobal;
  late bool isRegistered = false;

  late final Nyxx _client;

  SlashCommand._new(this._client, this.name, this.description, this.args, {this.guild}) {
    this.isGlobal = guild == null;
  }

  Future<SlashCommand> _register() async {
    final options = List<Map<String, dynamic>>.generate(
        this.args.length, (i) => this.args[i]._build());

    final response = await this._client.httpEndpoints.sendRawRequest(
      "/applications/${this._client.app.id.toString()}/commands",
      "POST",
      body: {
        "name": this.name,
        "description": this.description,
        "options": options.isNotEmpty ? options : null
      },
    );

    if (response is HttpResponseError) {
      return Future.error(response);
    }
    this.isRegistered = true;
    return Future.value(this);
  }

}