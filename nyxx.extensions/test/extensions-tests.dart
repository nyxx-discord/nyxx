import "package:nyxx.extensions/emoji.dart";

main() async {
  final emojis = await getAllEmojiDefinitions();
  assert(emojis.isEmpty);
}