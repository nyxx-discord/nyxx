import 'dart:io';

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

  test('AttachmentBuilder.fromFile', () async {
    final builder = await AttachmentBuilder.fromFile(File('test/files/1.png'));

    expect(builder.data, equals(await File('test/files/1.png').readAsBytes()));
    expect(builder.fileName, equals('1.png'));
  });
}
