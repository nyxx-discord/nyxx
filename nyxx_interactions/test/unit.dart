import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/interactions.dart";

import "package:test/test.dart";

final client = NyxxRest("dum", 0);
final slashCommandNameRegexMatcher = matches(slashCommandNameRegex);

void main() {
  group("test utils", () {
    test("test slash command regex", () {
      expect("test", slashCommandNameRegexMatcher);
      expect("Atest", slashCommandNameRegexMatcher);
      expect("test-test", slashCommandNameRegexMatcher);

      expect("test.test", isNot(slashCommandNameRegexMatcher));
      expect(".test", isNot(slashCommandNameRegexMatcher));
      expect("*test", isNot(slashCommandNameRegexMatcher));
      expect("/test", isNot(slashCommandNameRegexMatcher));
      expect("\\test", isNot(slashCommandNameRegexMatcher));
    });
  });
}
