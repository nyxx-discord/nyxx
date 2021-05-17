import "dart:async";

import "package:nyxx/nyxx.dart";
import "package:nyxx_extensions/emoji.dart";
import "package:nyxx_extensions/pagination.dart";
import "package:nyxx_extensions/src/utils.dart";
import "package:test/expect.dart";
import "package:test/scaffolding.dart";

void main() async {
  test("Basic tests", () async {
    final emojis = await getAllEmojiDefinitions(cache: true);
    expect(emojis, isNotEmpty);

    final emojisFromCache = await getAllEmojiDefinitions();
    expect(emojisFromCache, isNotEmpty);
  });

  group("Pagination tests", () {
    test("BasicPaginationHandler", () async {
      final pages = [
        "This is first page",
        "This is second page",
      ];

      final basicPaginationHandler = BasicPaginationHandler(pages);

      expect(basicPaginationHandler.dataLength, 2);
      expect(basicPaginationHandler.pages, pages);

      final initialPage = await basicPaginationHandler.generateInitialPage();
      expect(initialPage.runtimeType, MessageBuilder);
      expect(initialPage.content, pages[0]);

      final secondPage = await basicPaginationHandler.generatePage(1);
      expect(secondPage.runtimeType, MessageBuilder);
      expect(secondPage.content, pages[1]);

      expect(() async => await basicPaginationHandler.generatePage(2), throwsRangeError);
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
