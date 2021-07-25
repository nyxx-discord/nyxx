part of emoji;

List<EmojiDefinition> _emojisCache = [];

Future<RawApiMap> _downloadEmojiData() async {
  final request = http.Request("GET", emojiDataUri);
  final requestBody = await (await request.send()).stream.bytesToString();

  return jsonDecode(requestBody) as RawApiMap;
}

/// Emoji definitions uri
final Uri emojiDataUri = Uri.parse("https://static.emzi0767.com/misc/discordEmojiMap.json");

/// Returns emoji based on given [predicate]. Allows to cache results via [cache] parameter.
Future<EmojiDefinition> filterEmojiDefinitions(bool Function(EmojiDefinition) predicate, {bool cache = false}) async =>
    getAllEmojiDefinitions(cache: cache).firstWhere(predicate);

/// Returns all possible [EmojiDefinition]s. Allows to cache results via [cache] parameter.
/// If emojis are cached it will resolve immediately with result.
Stream<EmojiDefinition> getAllEmojiDefinitions({bool cache = false}) async* {
  if (_emojisCache.isNotEmpty) {
    yield* Stream.fromIterable(_emojisCache);
  }

  final rawData = await _downloadEmojiData();

  for (final emojiDefinition in rawData["emojiDefinitions"]) {
    final definition = EmojiDefinition._new(emojiDefinition as RawApiMap);

    if(cache) {
      _emojisCache.add(definition);
    }

    yield definition;
  }
}
