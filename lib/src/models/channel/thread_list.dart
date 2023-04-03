import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class ThreadList with ToStringHelper {
  final List<Thread> threads;

  final List<ThreadMember> members;

  final bool hasMore;

  ThreadList({
    required this.threads,
    required this.members,
    required this.hasMore,
  });
}
