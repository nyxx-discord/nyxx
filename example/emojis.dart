import 'package:nyxx/nyxx.dart';

void main(List<String> args) {
    // Create new bot instance. Replace string with your token
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged)
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();
  bot.eventsWs.onReady.listen((_) {
    print('Ready!');
  });
  // This event is called when a message is received
  bot.eventsWs.onMessageReceived.listen((event) async {
    if(event.message.content == '!emoji') {
      final emoji = bot.emojis.values.firstWhere((emo) => emo.name == 'some_emoji');
      final msg = await event.message.channel.sendMessage(MessageBuilder.content('Look at this emoji: $emoji'));
      msg.createReaction(emoji);
      // For unicode emoji use `UnicodeEmoji` class
      msg.createReaction(UnicodeEmoji('🤔'));
    }
  });

  // This event is called when a reaction has been added to a message
  bot.eventsWs.onMessageReactionAdded.listen((event) {
    if (event.emoji is UnicodeEmoji) {
      event.message?.channel.sendMessage(
        MessageBuilder.content(
          'Woah! This is a unicode emoji: ${event.emoji}',
        ),
      );
    } else if (event.emoji is IGuildEmojiPartial) {
      final emoji = (event.emoji as IGuildEmojiPartial).resolve();
      if (emoji?.name == 'some_emoji') {
        event.message?.channel.sendMessage(
          MessageBuilder.content('Woah! This is a custom emoji: $emoji'),
        );
      }
    }
  });
}
