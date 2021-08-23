part of nyxx_interactions;

/// Represents slash command that is returned from Discord API.
class SlashCommand extends SnowflakeEntity {
  /// Unique id of the parent application
  late final Snowflake applicationId;

  /// Command name to be shown to the user in the Slash Command UI
  late final String name;

  /// Command description shown to the user in the Slash Command UI
  late final String description;

  /// The arguments that the command takes
  late final List<CommandOption> options;

  /// The type of command
  late final SlashCommandType type;

  /// Guild id of the command, if not global
  late final Cacheable<Snowflake, Guild>? guild;

  /// Whether the command is enabled by default when the app is added to a guild
  late final bool defaultPermissions;

  SlashCommand._new(RawApiMap raw, Nyxx client): super(Snowflake(raw["id"])) {
    this.applicationId = Snowflake(raw["application_id"]);
    this.name = raw["name"] as String;
    this.description = raw["description"] as String;
    this.type = SlashCommandType(raw["type"] as int? ?? 1);
    this.guild = raw["guild_id"] != null
      ? CacheUtility.createCacheableGuild(client, Snowflake(raw["guild_id"]))
      : null;
    this.defaultPermissions = raw["default_permission"] as bool? ?? true;

    this.options = [
      if (raw["options"] != null)
        for(final optionRaw in raw["options"])
          CommandOption._new(optionRaw as RawApiMap)
    ];
  }
}
