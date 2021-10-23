import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/utils/extensions.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
	group("Snowflake", () {
		test(".toSnowflake()", () {
			const rawSnowflake = 901383075009806336;
			final snowflake = rawSnowflake.toSnowflake();

			expect(snowflake.id, rawSnowflake);
		});

		test("DateTime", () {
			final snowflake = Snowflake(901383332011593750);

			expect(snowflake.timestamp, DateTime.fromMillisecondsSinceEpoch(1634976933244).toUtc());
		});
	});
}
