import 'dart:io';

import 'package:path/path.dart' as path_lib;

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/message/attachment.dart';

class AttachmentBuilder extends Builder<Attachment> {
  List<int> data;

  String fileName;

  String? description;

  AttachmentBuilder({required this.data, required this.fileName, this.description});

  static Future<AttachmentBuilder> fromFile(File file, {String? description}) async {
    final data = await file.readAsBytes();

    return AttachmentBuilder(
      data: data,
      fileName: path_lib.basename(file.path),
      description: description,
    );
  }

  @override
  Map<String, Object?> build() => {
        'filename': fileName,
        if (description != null) 'description': description,
      };
}
