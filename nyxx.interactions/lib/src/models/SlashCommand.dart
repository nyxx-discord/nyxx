part of nyxx_interactions;

/// This class contains data about a slash command and is returned after registering one.
class SlashCommand {
  /// The name of your command.
  late final String name;

  /// The description of your command.
  late final String description;

  /// The args registered for a command
  late final List<SlashArg> args;

  /// If you command is registered globally
  late final bool isGlobal;

  /// When you command is only for one guild the [SlashCommand.guild] will contain a [Cacheable] for
  late final Cacheable<Snowflake, Guild>? guild;

  SlashCommand._new(
      Nyxx client, this.name, this.args, this.description, Snowflake? guildId) {
    this.isGlobal = guildId == null;
    this.guild = guildId != null
        ? CacheUtility.createCacheableGuild(client, Snowflake(guildId))
        : null;
  }

  Map<String, dynamic> _build() {
    final options = List<Map<String, dynamic>>.generate(
        this.args.length, (i) => this.args[i]._build());

    return {
      "name": this.name,
      "description": this.description,
      "options": options.isNotEmpty ? options : null
    };
  }
}
