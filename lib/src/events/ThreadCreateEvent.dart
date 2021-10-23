import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IThreadCreateEvent {
  /// The thread that was just created
  IThreadChannel get thread;
}

/// Fired when a thread is created
class ThreadCreateEvent implements IThreadCreateEvent {
  /// The thread that was just created
  @override
  late final IThreadChannel thread;

  /// Creates an instance of [ThreadCreateEvent]
  ThreadCreateEvent(RawApiMap raw, INyxx client) {
    this.thread = ThreadChannel(client, raw["d"] as RawApiMap);

    if (client.cacheOptions.channelCachePolicyLocation.event && client.cacheOptions.channelCachePolicy.canCache(this.thread)) {
      client.channels[this.thread.id] = this.thread;
    }
  }
}
