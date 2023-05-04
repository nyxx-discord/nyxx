import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('GroupDmUpdateBuilder', () {
    final builder = GroupDmUpdateBuilder(name: 'test', icon: [0, 1, 2]);

    expect(builder.build(), equals({'name': 'test', 'icon': 'AAEC'}));
  });
}
