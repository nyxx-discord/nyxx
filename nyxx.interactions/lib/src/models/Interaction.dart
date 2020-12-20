part of nyxx_interactions;

class Interaction extends SnowflakeEntity implements Disposable {
  /// Reference to bot instance
  final Nyxx client;

  late final InteractionType type;

  late final CommandInteractionData? data;

  late final Snowflake guild_id;

  late final Snowflake channel_id;

  late final User author;

  late final String token;

  late final int version;

  Interaction._new(
    this.client,
    Map<String, dynamic> raw,
  ) : super(Snowflake(raw["id"])) {
    switch (raw["type"] as int) {
      case 1:
        {
          this.type = InteractionType.Ping;
          break;
        }
      case 2:
        {
          this.type = InteractionType.ApplicationCommand;
          break;
        }
      default:
        {
          this.type = InteractionType.Unknown;
          break;
        }
    }

    this.guild_id = Snowflake(raw["guild_id"]);
    this.channel_id = Snowflake(raw["channel_id"]);
    this.author =
  }

  @override
  Future<void> dispose() => Future.value(null);
}
