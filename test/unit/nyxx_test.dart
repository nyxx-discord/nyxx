import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/exceptions/missing_token_error.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  test("nyxx rest constructor", () {
    expect(() => NyxxFactory.createNyxxRest("", 0, Snowflake.zero(), options: ClientOptions()), throwsA(isA<MissingTokenError>()));
    expect(() => NyxxFactory.createNyxxRest("test", 0, Snowflake.zero(), options: ClientOptions()), isNotNull);
  });
}
