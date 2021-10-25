import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  test(".fromInt", () {
    final firstColor = DiscordColor.fromInt(0);
    final secondColor = DiscordColor.fromInt(8224125);

    expect(0, equals(firstColor.value));
    expect(8224125, equals(secondColor.value));
  });

  test(".fromRgb", () {
    final firstColor = DiscordColor.fromRgb(0, 0, 0);
    final secondColor = DiscordColor.fromRgb(125, 125, 125);

    expect(0, equals(firstColor.value));
    expect(8224125, equals(secondColor.value));
  });

  test(".fromDouble", () {
    final firstColor = DiscordColor.fromDouble(0, 0, 0);
    final secondColor = DiscordColor.fromDouble(1, 1, 1);

    expect(0, equals(firstColor.value));
    expect(16777215, equals(secondColor.value));
  });

  test(".fromHexString", () {
    expect(() => DiscordColor.fromHexString(''), throwsA(isA<ArgumentError>()));

    final firstColor = DiscordColor.fromHexString('#000000');
    final secondColor = DiscordColor.fromHexString('000000');

    expect(0, equals(firstColor));
    expect(0, equals(secondColor));
  });

  test("base values", () {
    final firstColor = DiscordColor.fromHexString('#646464');

    expect(100, equals(firstColor.r));
    expect(100, equals(firstColor.g));
    expect(100, equals(firstColor.b));
  });

  test(".toString", () {
    final firstColor = DiscordColor.fromHexString('#646464');
    final secondColor = DiscordColor.fromHexString('#000000');

    expect('#646464', equals(firstColor.toString()));
    expect('#000000', equals(secondColor.toString()));
  });
}
