import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';

// TODO: Better generic here?
class PresenceBuilder extends CreateBuilder<PresenceUpdateEvent> {
  final DateTime? since;

  // TODO
  //final List<ActivityBuilder> activities;

  final CurrentUserStatus status;

  final bool isAfk;

  PresenceBuilder({this.since, required this.status, required this.isAfk});

  @override
  Map<String, Object?> build() => {
        'since': since?.millisecondsSinceEpoch,
        'status': status.value,
        'afk': isAfk,
      };
}

enum CurrentUserStatus {
  online._('online'),
  dnd._('dnd'),
  idle._('idle'),
  invisible._('invisible'),
  offline._('offline');

  final String value;

  const CurrentUserStatus._(this.value);

  @override
  String toString() => 'CurrentUserStatus($value)';
}
