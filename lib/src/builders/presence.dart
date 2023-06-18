import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';
import 'package:nyxx/src/models/presence.dart';

class PresenceBuilder extends CreateBuilder<PresenceUpdateEvent> {
  final DateTime? since;

  final List<ActivityBuilder>? activities;

  final CurrentUserStatus status;

  final bool isAfk;

  PresenceBuilder({this.since, this.activities, required this.status, required this.isAfk});

  @override
  Map<String, Object?> build() => {
        'since': since?.millisecondsSinceEpoch,
        if (activities != null) 'activities': activities!.map((e) => e.build()).toList(),
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

class ActivityBuilder extends CreateBuilder<Activity> {
  final String name;

  final ActivityType type;

  final Uri? url;

  ActivityBuilder({required this.name, required this.type, this.url});

  @override
  Map<String, Object?> build() => {
        'name': name,
        'type': type.value,
        if (url != null) 'url': url!.toString(),
      };
}
