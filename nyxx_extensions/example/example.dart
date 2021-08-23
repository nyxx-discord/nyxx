import "package:nyxx/nyxx.dart";
import "package:nyxx_extensions/emoji.dart" as emoji_extension;
import "package:nyxx_extensions/src/message_resolver/message_resolver.dart" as message_resolver_extension;

// nyxx.extensions contains several different extensions
// that could simplify making and implementing bots.
void main() async {
  // Emoji extension would allow to download and fetch discord emoji definitions
  // from resource shared by Emzi.
  // Emoji utils can cache results to do not download json document each time
  final allEmojis = emoji_extension.getAllEmojiDefinitions();

  // Its also possible to filter the emojis based on predicate
  final filteredEmojis = emoji_extension.filterEmojiDefinitions(
          (emojiDefinition) => emojiDefinition.primaryName.startsWith("smile")
  );

  // Needed for next extension
  final bot = Nyxx("token", GatewayIntents.allUnprivileged);

  // Message Resolver extension allows to transform raw string message content
  // to format that user is seeing
  final messageResolver = message_resolver_extension.MessageResolver(bot);

  // resolve method will return message according to set handling settings in
  // MessageResolver constructor.
  final resolvedMessage = messageResolver.resolve("This is raw content. <!@123>");
}
