import "package:nyxx_extensions/emoji.dart";

main() async {
  final emojis = await getAllEmojiDefinitions();
  assert(emojis.isNotEmpty, "Emojis cannot be empty");
}
