import 'dart:io';

import "package:nyxx.extensions/emoji.dart";

main() async {
  print("Memory: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB");

  final stopwatch = Stopwatch()..start();

  await filterEmojiDefinitions((emoji) => emoji.primaryName == "joy", cache: true);

  print("TIME: ${stopwatch.elapsedMilliseconds} ms");

  print("Memory: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB");

  stopwatch.reset();

  await filterEmojiDefinitions((emoji) => emoji.primaryName == "cry", cache: true);

  print("TIME: ${stopwatch.elapsedMilliseconds} ms");
  print("Memory: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB");

  stopwatch.reset();

  await filterEmojiDefinitions((emoji) => emoji.primaryName == "tired_face", cache: true);

  print("TIME: ${stopwatch.elapsedMilliseconds} ms");
  print("Memory: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB");
}