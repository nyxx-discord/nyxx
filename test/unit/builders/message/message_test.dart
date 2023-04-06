import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('MessageBuilder', () {
    final builder = MessageBuilder(
      allowedMentions: AllowedMentions.users([Snowflake.zero]),
      attachments: [
        AttachmentBuilder(data: [1, 2, 3], fileName: 'test.dart'),
      ],
      content: 'test content',
      embeds: [
        Embed(
          title: 'test embed title',
          description: 'A test embed description',
          url: Uri.https('discord.com', '/channels/@me'),
          timestamp: DateTime.utc(2022),
          color: DiscordColor.fromRgb(0, 0, 0),
          footer: EmbedFooter(text: 'footer text', iconUrl: null, proxiedIconUrl: null),
          image: EmbedImage(
            url: Uri.parse('https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg'),
            proxiedUrl: null,
            height: null,
            width: null,
          ),
          thumbnail: EmbedThumbnail(
            url: Uri.parse('https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg'),
            proxiedUrl: null,
            height: null,
            width: null,
          ),
          video: EmbedVideo(url: Uri.https('example.com'), proxiedUrl: null, height: null, width: null),
          provider: EmbedProvider(name: 'nyxx', url: null),
          author: EmbedAuthor(name: 'test embed author', url: null, iconUrl: null, proxyIconUrl: null),
          fields: [
            EmbedField(name: 'whoops', value: 'no error here', inline: false),
          ],
        ),
      ],
      nonce: '1234',
      replyId: null,
      stickerIds: [Snowflake.zero],
      suppressEmbeds: false,
      suppressNotifications: true,
      tts: false,
    );

    expect(
      builder.build(),
      equals({
        'content': 'test content',
        'nonce': '1234',
        'tts': false,
        'embeds': [
          {
            'title': 'test embed title',
            'description': 'A test embed description',
            'url': 'https://discord.com/channels/@me',
            'timestamp': '2022-01-01T00:00:00.000Z',
            'color': 0,
            'footer': {
              'text': 'footer text',
            },
            'image': {
              'url': 'https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg',
            },
            'thumbnail': {
              'url': 'https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg',
            },
            'video': {
              'url': 'https://example.com',
            },
            'provider': {
              'name': 'nyxx',
            },
            'author': {
              'name': 'test embed author',
            },
            'fields': [
              {
                'name': 'whoops',
                'value': 'no error here',
                'inline': false,
              },
            ],
          },
        ],
        'allowed_mentions': {
          'users': ['0'],
          'replied_user': false,
        },
        'sticker_ids': ['0'],
        'attachments': [
          {
            'filename': 'test.dart',
          }
        ],
        'flags': 4096,
      }),
    );
  });
}
