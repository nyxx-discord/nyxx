import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  test("nyxx rest constructor", () {
    expect(() => NyxxFactory.createNyxxRest("", 0, Snowflake.zero(), ignoreExceptions: false, useDefaultLogger: false, options: ClientOptions()), throwsA(isA<MissingTokenError>()));
    expect(() => NyxxFactory.createNyxxRest("test", 0, Snowflake.zero(), ignoreExceptions: true, useDefaultLogger: false, options: ClientOptions()), isNotNull);
  });
}
