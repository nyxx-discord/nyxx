import 'package:nyxx/nyxx.dart';

class SystemChannelFlags extends IEnum<int> {
  static const suppressJoinNotifications = SystemChannelFlags._create(1 << 0);
  static const suppressPremiumSubscriptions = SystemChannelFlags._create(1 << 1);
  static const suppressGuildReminderBoostNotifications = SystemChannelFlags._create(1 << 2);
  static const suppressJoinNotificationReplies = SystemChannelFlags._create(1 << 3);

  const SystemChannelFlags._create(int? value) : super(value ?? 0);
  SystemChannelFlags.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}
