import 'dart:io';

import 'package:path/path.dart' as path_lib;

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/message/attachment.dart';

class AttachmentBuilder extends Builder<Attachment> {
  final List<int> data;

  final String? fileName;

  final String? description;

  AttachmentBuilder({required this.data, this.fileName, this.description});

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
        if (fileName != null) 'filename': fileName,
        if (description != null) 'description': description,
      };
}