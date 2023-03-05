//<:Pepega:547759324836003842>

import "package:nyxx/nyxx.dart";
import 'dart:io';

// Main function
void main() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket(Platform.environment['BOT_TOKEN']!, GatewayIntents.allUnprivileged | GatewayIntents.messageContent)
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((e) async {
    // Check if message content equals "!ping"
    if (e.message.content == "!ping") {
      bot.httpEndpoints.fetchChannel(Snowflake(961916452967944223));

      e.message.guild?.getFromCache()?.shard;
      // Send "Pong!" to channel where message was received
      e.message.channel.sendMessage(MessageBuilder.content(IBaseGuildEmoji.fromId(Snowflake(502563517774299156), bot).formatForMessage()));
    }

    print(await (await e.message.guild?.getOrDownload())!.getBans().toList());

    if (e.message.content == "!create-thread") {
      bot.httpEndpoints.startForumThread(
        Snowflake(961916452967944223),
        ForumThreadBuilder(
          'test',
          message: MessageBuilder.content(
            'this is test content <@${e.message.author.id}>',
          ),
        ),
      );
    }
  });
}
