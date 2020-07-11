part of nyxx.extensions.emoji;

List<EmojiDefinition> _emojisCache = [];

Future<Map<String, dynamic>> _downloadEmojiData() async {
  final request = w_transport.JsonRequest()
    ..uri = emojiDataUri;

  return (await request.send("GET")).body.asJson() as Map<String, dynamic>;
}

/// Emoji definitions uri
final Uri emojiDataUri = Uri.parse("https://static.emzi0767.com/misc/discordEmojiMap.json");

/// Returns emoji based on given [predicate]. Allows to cache results via [cache] parameter.
Future<EmojiDefinition> filterEmojiDefinitions(bool Function(EmojiDefinition) predicate, {bool cache = false}) async =>
    (await getAllEmojiDefinitions(cache: cache)).firstWhere(predicate);

/// Returns all possible [EmojiDefinition]s. Allows to cache results via [cache] parameter.
Future<Iterable<EmojiDefinition>> getAllEmojiDefinitions({bool cache = false}) async {
  if(_emojisCache.isNotEmpty) {
    return Future.value(_emojisCache);
  }

  final rawData = await _downloadEmojiData();

  final _emojis = [
    for(final ed in rawData["emojiDefinitions"])
      EmojiDefinition._new(ed as Map<String, dynamic>)
  ];
  
  if(cache) {
    _emojisCache = _emojis;
  }

  return _emojis;
}