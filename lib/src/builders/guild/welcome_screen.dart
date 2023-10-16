import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/guild/welcome_screen.dart';

class WelcomeScreenUpdateBuilder extends UpdateBuilder<WelcomeScreen> {
  bool? isEnabled;

  List<WelcomeScreenChannel>? channels;

  String? description;

  WelcomeScreenUpdateBuilder({this.isEnabled, this.channels, this.description = sentinelString});

  @override
  Map<String, Object?> build() => {
        if (isEnabled != null) 'enabled': isEnabled,
        if (channels != null)
          'channels': [
            for (final channel in channels!)
              {
                'channel_id': channel.channelId.toString(),
                'description': channel.description,
                'emoji_id': channel.emojiId?.toString(),
                'emoji_name': channel.emojiName,
              },
          ],
        if (!identical(description, sentinelString)) 'description': description,
      };
}
