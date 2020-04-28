library nyxx.vm;

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:w_transport/vm.dart' show configureWTransportForVM;

import 'src/_internals.dart' show setup, browser, operatingSystem;
import 'nyxx.dart';

export 'nyxx.dart';

Nyxx NyxxVm(String token, {ClientOptions? options, bool ignoreExceptions = true}) {
  configureWTransportForVM();
  setup = true;
  browser = false;
  operatingSystem = Platform.operatingSystem;

  return Nyxx(token,
      options: options, ignoreExceptions: ignoreExceptions);
}

/// Sets up default logger
void setupDefaultLogging([Level? loglevel]) {
  Logger.root.level = loglevel ?? Level.ALL;

  Logger.root.onRecord.listen((LogRecord rec) {
    String color = "";
    if (rec.level == Level.WARNING)
      color = "\u001B[33m";
    else if (rec.level == Level.SEVERE)
      color = "\u001B[31m";
    else if (rec.level == Level.INFO)
      color = "\u001B[32m";
    else
      color = "\u001B[0m";

    print('[${DateTime.now()}] '
        '$color[${rec.level.name}] [${rec.loggerName}]\u001B[0m: '
        '${rec.message}');
  });
}

extension EmbedAuthorDownload on EmbedAuthor {
  Future<File> downloadFile(File file) =>
      download().then((data) => file.writeAsBytes(data));
}

extension EmbedFooterDownload on EmbedFooter {
  Future<File> downloadFile(File file) =>
      download().then((data) => file.writeAsBytes(data));
}

extension EmbedThumbnailDownload on EmbedThumbnail {
  Future<File> downloadFile(File file) =>
      download().then((data) => file.writeAsBytes(data));
}

extension EmbedVideoDownload on EmbedVideo {
  Future<File> downloadFile(File file) =>
      download().then((data) => file.writeAsBytes(data));
}

extension AttachmentDownload on Attachment {
  Future<File> downloadFile(File file) =>
      download().then((data) => file.writeAsBytes(data));
}
