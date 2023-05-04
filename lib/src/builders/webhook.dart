import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';

class WebhookBuilder extends CreateBuilder<Webhook> {
  final String name;

  // Not used in build, but used to determine the proper route when creating webhooks.
  final Snowflake channelId;

  final ImageBuilder? avatar;

  WebhookBuilder({required this.name, required this.channelId, this.avatar});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (avatar != null) 'avatar': avatar!.build(),
      };
}

class WebhookUpdateBuilder extends UpdateBuilder<Webhook> {
  final String? name;

  final ImageBuilder? avatar;

  final Snowflake? channelId;

  WebhookUpdateBuilder({
    this.name,
    this.avatar = sentinelImageBuilder,
    this.channelId,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(avatar, sentinelImageBuilder)) 'avatar': avatar?.build(),
        if (channelId != null) 'channel_id': channelId.toString(),
      };
}
