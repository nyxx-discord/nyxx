import "package:nyxx.extensions/emoji.dart";

main() async {
  final stopwatch = Stopwatch()..start();

  await filterEmojiDefinitions((emoji) => emoji.primaryName == "joy", cache: true);

  print(stopwatch.elapsedMilliseconds);
  stopwatch.reset();

  await filterEmojiDefinitions((emoji) => emoji.primaryName == "cry", cache: true);

  print(stopwatch.elapsedMilliseconds);
  stopwatch.reset();

  await filterEmojiDefinitions((emoji) => emoji.primaryName == "tired_face", cache: true);

  print(stopwatch.elapsedMilliseconds);
}