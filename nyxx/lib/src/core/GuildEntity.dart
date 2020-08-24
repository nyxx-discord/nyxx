part of nyxx;

/// Represents entity which bound to guild, eg. member, emoji, message, role.
abstract class GuildEntity {
  /// Reference to [Guild] object
  Guild? get guild;

  /// Id of [Guild]
  Snowflake get guildId;
}
