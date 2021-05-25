part of nyxx;

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
    this.private = true;
  }

  /// Set the time after which the thread automatically archives itself.
  void setArchiveAfter(ThreadArchiveTime time) => this.archiveAfter = time;

  /// Make the thread private
  void setPrivate() => this.private = true;

  /// Make the thread public
  void setPublic() => this.private = false;

  @override
  Map<String, dynamic> _build() => <String, dynamic>{
    "auto_archive_duration": this.archiveAfter.value,
    "name": name,
    "type": private ? 12 : 11
  };
}

/// Simplifies the process of setting an auto archive time.
class ThreadArchiveTime extends IEnum<int> {
  const ThreadArchiveTime._new(int value) : super(value);

  /// Archive after an hour
  static const ThreadArchiveTime hour = ThreadArchiveTime._new(60);

  /// Archive after an day
  static const ThreadArchiveTime day = ThreadArchiveTime._new(1440);

  /// Archive after an week
  static const ThreadArchiveTime week = ThreadArchiveTime._new(10080);

  @override
  String toString() => _value.toString();
}
