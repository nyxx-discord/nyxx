import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/builders/sound.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/soundboard/soundboard.dart';
import 'package:nyxx/src/utils/building_helpers.dart';

class SoundboardSoundBuilder extends CreateBuilder<SoundboardSound> {
  String name;

  SoundBuilder sound;

  double? volume;

  Emoji? emoji;

  String? emojiName;

  Snowflake? emojiId;

  SoundboardSoundBuilder({required this.name, required this.sound, this.volume, this.emojiName, this.emojiId});

  @override
  Map<String, Object?> build() => {
        'name': name,
        'sound': sound.buildDataString(),
        if (volume != null) 'volume': volume,
        ...makeEmojiMap(emojiId: emojiId, emojiName: emojiName),
      };
}

class SoundboardSoundUpdateBuilder extends UpdateBuilder<SoundboardSound> {
  String name;

  double? volume;

  String? emojiName;

  Snowflake? emojiId;

  SoundboardSoundUpdateBuilder({required this.name, this.volume = sentinelDouble, this.emojiName = sentinelString, this.emojiId = sentinelSnowflake});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (volume != sentinelDouble) 'volume': volume,
        if (!(identical(emojiName, sentinelString) || identical(emojiId, sentinelSnowflake))) ...makeEmojiMap(emojiId: emojiId, emojiName: emojiName),
      };
}
