import "dart:async";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commander/commander.dart";

// Temporary storage for prefixes per guild
// Note that this implementation is just proof of concept
// and in production you should use some kind of database to store data
final prefixes = <Snowflake, String>{};

const defaultPrefix = "!";

FutureOr<String?> prefixHandler(Message message) {
  // Check if we are in DMs, if true then return default prefix
  if (message is DMMessage) {
    return defaultPrefix;
  }

  final guildMessage = message as GuildMessage; // case message to GuildMessage since we are sure we are not in DMs
  final prefixForGuild = prefixes[guildMessage.guild.id]; // Get prefix for guild id. Will return null if not present

  return prefixForGuild ?? defaultPrefix; // return prefix for guild if not null or default prefix otherwise
}

void main() {
  // Start bot
  final bot = Nyxx("MzYxOTQ5MDUwMDE2MjM1NTIw.WclRUg.RtxcvnSWi5nLhzYuMKGKOtJuXTM", GatewayIntents.allUnprivileged);

  // Start commander with prefix `!`
  Commander(bot, prefixHandler: prefixHandler) // prefixHandler will handle deciding which guild can use which prefix
    ..registerCommand("ping", (context, message) { // register command ping that will answer pong
      context.reply(MessageBuilder.content("Pong"));
    })
    ..registerCommand("setPrefix", (context, message) {
      // Check if message was sent in DMs
      if (context.guild == null) {
        context.reply(MessageBuilder.content("Cannot set prefix in DMs"));
        return;
      }

      final args = context.getArguments(); // Context#getArguments will return stuff after prefix and command name.

      // Check if user passed any arguments to command
      if (args.isEmpty) {
        context.reply(MessageBuilder.content("After command name there has to be desired prefix you want to set"));
        return;
      }

      // Since we care only about prefix we are using .first to take first element
      // and set given prefix for guild
      prefixes[context.guild!.id] = args.first;

      context.reply(MessageBuilder.content("Prefix set to `${args.first}` successfully!"));
    });
}
