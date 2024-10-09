import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/builders/sound.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/soundboard/soundboard.dart';

Map<String, String> _makeEmojiMap(Emoji? emoji) => {
      if (emoji case final TextEmoji emoji?) 'emoji_name': emoji.name,
      if (emoji case final GuildEmoji emoji?) 'emoji_id': emoji.id.toString(),
    };

class SoundboardSoundBuilder extends CreateBuilder<SoundboardSound> {
  String name;

  SoundBuilder sound;

  double? volume;

  Emoji? emoji;

  SoundboardSoundBuilder({required this.name, required this.sound, this.volume, this.emoji});

  @override
  Map<String, Object?> build() => {
        'name': name,
        'sound': sound.buildDataString(),
        if (volume != null) 'volume': volume,
        ..._makeEmojiMap(emoji),
      };
}

class UpdateSoundboardSoundBuilder extends UpdateBuilder<SoundboardSound> {
  String name;

  double? volume;

  Emoji? emoji;

  UpdateSoundboardSoundBuilder({required this.name, this.volume = sentinelDouble, this.emoji = sentinelEmoji});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (volume != sentinelDouble) 'volume': volume,
        if (emoji != sentinelEmoji) ..._makeEmojiMap(emoji),
      };
}
