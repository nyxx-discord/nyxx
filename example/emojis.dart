import 'package:nyxx/nyxx.dart';

void main(List<String> args) {
  // Create new bot instance. Replace string with your token
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged | GatewayIntents.messageContent) // Here we use the privilegied intent message content to receive incoming messages.
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  bot.eventsWs.onReady.listen((_) {
    print('Ready!');
  });

  // This event is called when a message is received
  bot.eventsWs.onMessageReceived.listen((event) async {
    if (event.message.content == '!emoji') {
      final emoji = event.message.guild?.getFromCache()?.emojis.values.firstWhere((emo) => emo.name == 'nyxx');
      final msg = await event.message.channel.sendMessage(MessageBuilder.content('Look at this emoji: $emoji'));
      await msg.createReaction(emoji!);
      // For unicode emoji use `UnicodeEmoji` class
      await msg.createReaction(UnicodeEmoji('🤔'));
    }
  });

  // This event is called when a reaction has been added to a message
  bot.eventsWs.onMessageReactionAdded.listen((event) async {
    if (event.emoji is UnicodeEmoji) {
      await event.message?.channel.sendMessage(
        MessageBuilder.content(
          'Woah! This is a unicode emoji: ${event.emoji}',
        ),
      );
    } else if (event.emoji is IGuildEmojiPartial) {
      if (event.emoji is IResolvableGuildEmojiPartial) {
        final emoji = (event.emoji as IResolvableGuildEmojiPartial).resolve();
        await event.message?.channel.sendMessage(
          MessageBuilder.content(
            'Woah! This is a custom emoji: ${emoji.name}',
          ),
        );
      }
    }
  });
}
