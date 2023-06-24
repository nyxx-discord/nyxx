import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleGuildSticker = {
  "id": "0",
  "name": "sampleGuildSticker",
  "description": "Example description",
  "tags": "first,second,third",
  "type": 2,
  "format_type": 1,
  "available": true,
  "user": {
    "id": "0"
  },
  "sort_value": 1,
  "guild_id": "0",
};

final sampleGlobalSticker = {
  "id": "0",
  "name": "sampleGuildSticker",
  "description": "Example description",
  "tags": "first,second,third",
  "type": 2,
  "format_type": 1,
  "available": true,
  "sort_value": 1,
  "pack_id": "0",
};

void main() {
  testManager<GuildSticker, GuildStickerManager>(
      "GuildStickerManager",
      (config, client) => GuildStickerManager(config, client, guildId: Snowflake.zero),
      RegExp(r'/guilds/0/stickers/\d+'),
      '/guilds/0/stickers',
      sampleObject: sampleGuildSticker,
      sampleMatches: (GuildSticker sticker) {
        expect(sticker.id, equals(Snowflake.zero));
        expect(sticker.name, equals("sampleGuildSticker"));
        expect(sticker.description, equals("Example description"));
        expect(sticker.type, equals(StickerType.guild));
        expect(sticker.formatType, equals(StickerFormatType.png));
        expect(sticker.available, equals(true));
        expect(sticker.sortValue, equals(1));
        expect(sticker.guildId, equals(Snowflake.zero));
        expect(sticker.getTags(), equals(["first", "second", "third"]));
      },
      additionalParsingTests: [],
      additionalEndpointTests: [],
      createBuilder: StickerCreateBuilder(name: "cool_sticker", description: "cool description", tags: "cool,new,tags", file: ImageBuilder(data: [], format: 'png')),
      updateBuilder: StickerUpdateBuilder(name: "cool_new_name", tags: "cool,new,tags"),
  );

  testReadOnlyManager<GlobalSticker, GlobalStickerManager>(
      "GuildStickerManager",
      (config, client) => GlobalStickerManager(config, client),
      RegExp(r'/stickers/\d+'),
      sampleObject: sampleGlobalSticker,
      sampleMatches: (GlobalSticker sticker) {
        expect(sticker.id, equals(Snowflake.zero));
        expect(sticker.name, equals("sampleGuildSticker"));
        expect(sticker.description, equals("Example description"));
        expect(sticker.type, equals(StickerType.guild));
        expect(sticker.formatType, equals(StickerFormatType.png));
        expect(sticker.available, equals(true));
        expect(sticker.sortValue, equals(1));
        expect(sticker.packId, equals(Snowflake.zero));
        expect(sticker.getTags(), equals(["first", "second", "third"]));
      },
      additionalParsingTests: [],
      additionalEndpointTests: [],
  );
}