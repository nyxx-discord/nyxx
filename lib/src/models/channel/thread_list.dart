import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template thread_list}
/// A list of threads and thread members.
/// {@endtemplate}
class ThreadList with ToStringHelper {
  /// A list of threads.
  final List<Thread> threads;

  /// A list of thread members associated with [threads].
  final List<ThreadMember> members;

  /// Whether more results can be queried.
  final bool hasMore;

  /// {@macro thread_list}
  /// @nodoc
  ThreadList({
    required this.threads,
    required this.members,
    required this.hasMore,
  });
}
