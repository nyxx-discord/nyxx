import 'package:nyxx/src/nyxx.dart';

abstract class IReadyEvent {}

// TODO: ???
/// Sent when the client is ready.
class ReadyEvent implements IReadyEvent {
  /// Creates na instance of [ReadyEvent]
  ReadyEvent(INyxx client);
}
