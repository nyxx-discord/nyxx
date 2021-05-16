import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/interactions.dart";

void main() {
  final bot = Nyxx("<TOKEN>", GatewayIntents.allUnprivileged);
  Interactions(bot)
    ..registerSlashCommand(SlashCommandBuilder(
        "itest",
        "This is test command",
        [
          CommandOptionBuilder(CommandOptionType.subCommand, "subtest", "This is sub test")
            ..registerHandler((event) => event.respond(MessageBuilder.content("This is example command")))
        ],
        guild: 302360552993456135.toSnowflake()))
    ..syncOnReady();
}
