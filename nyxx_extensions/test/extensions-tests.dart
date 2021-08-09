import "dart:async";

import "package:nyxx/nyxx.dart";
import "package:nyxx_extensions/embedbuilder_extension.dart";
import "package:nyxx_extensions/emoji.dart";
import "package:nyxx_extensions/src/utils.dart";
import "package:test/expect.dart";
import "package:test/scaffolding.dart";

void main() async {
  test("Basic tests", () async {
    final emojis = await getAllEmojiDefinitions(cache: true).toList();
    expect(emojis, isNotEmpty);

    final emojisFromCache = await getAllEmojiDefinitions().toList();
    expect(emojisFromCache, isNotEmpty);
  });

  group("Embed Builder from Json", () {
    test("Embed Footer Builder test", () async {
      final data = <String, String?>{
        "text": "Footer Text",
        "icon_url": "https://cdn.discordapp.com/avatars/281314080923320321/e7e716c1a1efb236f9ff0e29a54f1ba2.png?size=128",
      };
      final footer = EmbedFooterBuilder().importJson(data);

      expect(footer.text, equals("Footer Text"));
      expect(footer.iconUrl, equals("https://cdn.discordapp.com/avatars/281314080923320321/e7e716c1a1efb236f9ff0e29a54f1ba2.png?size=128"));
    });

    test("Embed Author Builder test", () async {
      final data = <String, String?>{
        "name": "HarryET",
        "url": "https://discord.com",
        "icon_url": "https://cdn.discordapp.com/avatars/281314080923320321/e7e716c1a1efb236f9ff0e29a54f1ba2.png?size=128",
      };
      final author = EmbedAuthorBuilder().importJson(data);

      expect(author.name, equals("HarryET"));
      expect(author.url, equals("https://discord.com"));
      expect(author.iconUrl, equals("https://cdn.discordapp.com/avatars/281314080923320321/e7e716c1a1efb236f9ff0e29a54f1ba2.png?size=128"));
    });

    group("Embed Field Builder tests", () {
      test("with inline", () async {
        final data = <String, dynamic>{
          "name": "Example",
          "value": "This is an example text",
          "inline": true
        };
        final field = EmbedFieldBuilder().importJson(data);

        expect(field.name, equals("Example"));
        expect(field.content, equals("This is an example text"));
        expect(field.inline, equals(true));
      });

      test("without inline", () async {
        final data = <String, dynamic>{
          "name": "Example",
          "value": "This is an example text",
        };
        final field = EmbedFieldBuilder().importJson(data);

        expect(field.name, equals("Example"));
        expect(field.content, equals("This is an example text"));
        expect(field.inline, isNull);
      });

      test("accept empty values", () async {
        final data = <String, dynamic>{
          "name": "Example",
          "value": null,
          "inline": true
        };
        final field = EmbedFieldBuilder().importJson(data);

        expect(field.name, isNotEmpty);
        expect(field.content, isNull);
      });
    });

    test("Create embed from json", () async {
      final data = <String, dynamic>{
        "title": "title ~~(did you know you can have markdown here too?)~~",
        "description": "this supports [named links](https://discordapp.com) on top of the previously shown subset of markdown. ```\nyes, even code blocks```",
        "url": "https://discordapp.com",
        "color": 14515245,
        "timestamp": "2021-06-05T10:02:06.400Z",
        "footer": {
          "icon_url": "https://cdn.discordapp.com/embed/avatars/0.png",
          "text": "footer text"
        },
        "thumbnail": {
          "url": "https://cdn.discordapp.com/embed/avatars/0.png"
        },
        "image": {
          "url": "https://cdn.discordapp.com/embed/avatars/0.png"
        },
        "author": {
          "name": "author name",
          "url": "https://discordapp.com",
          "icon_url": "https://cdn.discordapp.com/embed/avatars/0.png"
        },
        "fields": [
          {
            "name": "🤔",
            "value": "some of these properties have certain limits...",
            "inline": false
          },
          {
            "name": "<:thonkang:219069250692841473>",
            "value": "are inline fields",
            "inline": true
          }
        ]
      };
      final embed = EmbedBuilder().importJson(data);
      expect(BuilderUtility.buildRawEmbed(embed), equals(data));
    });
  });

  group("Utils tests", () {
    test("StreamUtils.merge test", () {
      final streamController1 = StreamController<int>.broadcast();
      final stream1 = streamController1.stream;

      final streamController2 = StreamController<int>.broadcast();
      final stream2 = streamController2.stream;

      final combinedStream = StreamUtils.merge([stream1, stream2]);

      expect(combinedStream, emitsInOrder([1, 2, 3]));

      streamController1.add(1);
      streamController2.add(2);
      streamController2.add(3);

      streamController1.close();
      streamController2.close();
    });

    test("StringUtils.split", () {
      const str = "Five Five Five";
      expect(["Five ", "Five ", "Five"], StringUtils.split(str, 5));
    });

    test("StringUtils.splitEqually", () {
      const str = "Five";
      expect(["Fi", "ve"], StringUtils.splitEqually(str, 2));
    });
  });
}
