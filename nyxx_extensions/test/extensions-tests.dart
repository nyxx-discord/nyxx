import "package:nyxx_extensions/emoji.dart";

void main() async {
  final emojis = await getAllEmojiDefinitions();
  assert(emojis.isNotEmpty, "Emojis cannot be empty");
}
