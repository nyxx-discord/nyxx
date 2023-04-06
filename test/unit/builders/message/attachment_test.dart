import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('AttachmentBuilder', () {
    final builder = AttachmentBuilder(
      data: [1, 2, 3],
      description: 'A test description',
      fileName: 'foo.dart',
    );

    expect(
      builder.build(),
      equals({
        'filename': 'foo.dart',
        'description': 'A test description',
      }),
    );
  });
}
