import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';
import 'package:nyxx/src/utils/builders/builder.dart';

class ThreadBuilder extends Builder {
  /// The name fo the thread
  String? name;

  /// Whether or not the thread is private
  bool private = false;

  /// The time after which the thread is automatically archived.
  ThreadArchiveTime archiveAfter = ThreadArchiveTime.day;

  /// Create a public thread
  ThreadBuilder(this.name);

  /// Create a private thread
  ThreadBuilder.private(this.name) {
    private = true;
  }

  /// Set the time after which the thread automatically archives itself.
  void setArchiveAfter(ThreadArchiveTime time) => archiveAfter = time;

  /// Make the thread private
  void setPrivate() => private = true;

  /// Make the thread public
  void setPublic() => private = false;

  @override
  RawApiMap build() => <String, dynamic>{"auto_archive_duration": archiveAfter.value, "name": name, "type": private ? 12 : 11};
}

/// Simplifies the process of setting an auto archive time.
class ThreadArchiveTime extends IEnum<int> {
  /// Creates an instane of [ThreadArchiveTime]
  const ThreadArchiveTime(int value) : super(value);

  /// Archive after an hour
  static const ThreadArchiveTime hour = ThreadArchiveTime(60);

  /// Archive after an day
  static const ThreadArchiveTime day = ThreadArchiveTime(1440);

  /// Archive after 3 days
  static const ThreadArchiveTime threeDays = ThreadArchiveTime(4320);

  /// Archive after an week
  static const ThreadArchiveTime week = ThreadArchiveTime(10080);
}
