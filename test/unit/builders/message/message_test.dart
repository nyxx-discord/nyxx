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
        EmbedBuilder(
          title: 'test embed title',
          description: 'A test embed description',
          url: Uri.https('discord.com', '/channels/@me'),
          timestamp: DateTime.utc(2022),
          color: DiscordColor.fromRgb(0, 0, 0),
          footer: EmbedFooterBuilder(text: 'footer text'),
          image: EmbedImageBuilder(
            url: Uri.parse('https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg'),
          ),
          thumbnail: EmbedThumbnailBuilder(
            url: Uri.parse('https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg'),
          ),
          author: EmbedAuthorBuilder(name: 'test embed author'),
          fields: [
            EmbedFieldBuilder(name: 'whoops', value: 'no error here', isInline: false),
          ],
        ),
      ],
      nonce: '1234',
      stickerIds: [Snowflake.zero],
      // ignore: deprecated_member_use_from_same_package
      suppressEmbeds: false,
      // ignore: deprecated_member_use_from_same_package
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

  test('MessageUpdateBuilder', () {
    final builder = MessageUpdateBuilder(
      allowedMentions: AllowedMentions.users([Snowflake.zero]),
      attachments: [
        AttachmentBuilder(data: [1, 2, 3], fileName: 'test.dart'),
      ],
      content: 'test content',
      embeds: [
        EmbedBuilder(
          title: 'test embed title',
          description: 'A test embed description',
          url: Uri.https('discord.com', '/channels/@me'),
          timestamp: DateTime.utc(2022),
          color: DiscordColor.fromRgb(0, 0, 0),
          footer: EmbedFooterBuilder(text: 'footer text'),
          image: EmbedImageBuilder(
            url: Uri.parse('https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg'),
          ),
          thumbnail: EmbedThumbnailBuilder(
            url: Uri.parse('https://github.com/dart-lang/sdk/raw/main/docs/assets/Dart-platforms.svg'),
          ),
          author: EmbedAuthorBuilder(name: 'test embed author'),
          fields: [
            EmbedFieldBuilder(name: 'whoops', value: 'no error here', isInline: false),
          ],
        ),
      ],
      suppressEmbeds: true,
    );

    expect(
      builder.build(),
      equals({
        'content': 'test content',
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
        },
        'attachments': [
          {
            'filename': 'test.dart',
          }
        ],
        'flags': 4,
      }),
    );
  });
}
