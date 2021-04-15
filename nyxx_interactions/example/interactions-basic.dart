import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/interactions.dart";

void main() {
  // final bot = Nyxx("<%TOKEN%>", GatewayIntents.all);
  //
  // final interactions = Interactions(bot);
  //
  // interactions.registerCommand(SlashCommandBuilder(
  //   "echo", // The command name
  //   "echo a message", // The commands description
  //   [CommandOptionBuilder(CommandOptionType.string, "message", "the message to be echoed.")], // The commands arguments
  //   guild: Snowflake(""), // Replace with your guilds ID
  // ));
  //
  // bot.onReady.listen((event) {
  //   interactions.sync(); // Sync commands with API
  //   // Listen to slash commands being triggered
  //   interactions.onSlashCommand.listen((event) async {
  //     // Check if the name of the command is echo
  //     if (event.interaction.name == "echo") {
  //       // Reply with the message the user sent, showSource makes discord show the command the user sent in the channel.
  //       await event.respond(content: event.interaction.getArg("message"));
  //     }
  //   });
  // });
}
