import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/http/http_route.dart';
import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/utils/utils.dart';

/// All known routes for Discord's CDN endpoints.
/// Theses are used internally by specific classes; however it's possible to use
/// them like [IHttpEndpoints].
///
/// The docs assume the root (`/`) is `https://cdn.discordapp.com/`.
abstract class ICdnHttpEndpoints {
  /// Returns URL to ``/app-assets/[assetHash]``.
  /// With given [format] and [size].
  String appAsset(Snowflake clientId, String assetHash, {String format = 'webp', int? size});

  /// Returns URL to ``/app-icons/[iconHash]``.
  /// With given [format] and [size].
  String appIcon(Snowflake clientId, String iconHash, {String format = 'webp', int? size});

  /// Returns URL to ``/avatars/[avatarHash]``.
  /// With given [format], [size] and whether or not returns the animated version (if applicable) of this URL with [animated].
  String avatar(Snowflake id, String avatarHash, {String format = 'webp', int? size, bool animated = true});

  /// Returns URL to ``/banners/[bannerHash]``.
  /// With given [format], [size] and whether or not returns the animated version (if applicable) of this URL with [animated].
  String banner(Snowflake guildOrUserId, String hash, {String format = 'webp', int? size, bool animated = true});

  /// Returns URL to ``/channel-icons/[iconHash]``.
  /// With given [format] and [size].
  String channelIcon(Snowflake channelId, String iconHash, {String format = 'webp', int? size});

  /// Returns URL to ``/embed/avatars/{index}``.
  ///
  /// For non-migrated users to the new username system, the [discriminator] is passed as modulo 5 (`% 5`); and will lead to 0,1,2,3,4. (There's 5, but 5 modulo 5 will never give 5).
  /// For migrated users, the [id] is passed and is left shifted by 22 bits and then the result is modulo 6 (`% 6`). (For pink avatar).
  ///
  /// E.g:
  /// ```dart
  /// client.cdnHttpEndpoints.defaultAvatar(6712, 123456789123456789); // https://cdn.discordapp.com/embed/avatars/2.png
  /// ```
  String defaultAvatar(int discriminator, int id);

  /// Returns URL to ``/emojis/[emojiId]``.
  /// With given [format] and [size].
  String emoji(Snowflake emojiId, {String format = 'webp', int? size});

  /// Returns URL to ``/discovery-splashes/[splashHash]``.
  /// With given [format] and [size].
  String discoverySplash(Snowflake guildId, String splashHash, {String format = 'webp', int? size});

  /// Returns URL to ``/guilds/[guildId]/users/[userId]/[avatarHash]``.
  /// With given [format], [size] and whether or not returns the animated version (if applicable) of this URL with [animated].
  String memberAvatar(Snowflake guildId, Snowflake userId, String avatarHash, {String format = 'webp', int? size, bool animated = true});

  /// Returns URL tp ``/icons/[iconHash]``.
  /// With given [format], [size] and whether or not returns the animated version (if applicable) of this URL with [animated].
  String icon(Snowflake id, String iconHash, {String format = 'webp', int? size, bool animated = true});

  /// Returns URL to ``/role-icons/[roleIconHash]``.
  /// With given [format] and [size].
  String roleIcon(Snowflake roleId, String roleIconHash, {String format = 'webp', int? size});

  /// Returns URL to ``/splashes/[splashHash]``.
  /// With given [format] and [size].
  String splash(Snowflake guildId, String splashHash, {String format = 'webp', int? size});

  /// Returns URL to ``/stickers/[stickerId]``.
  /// With given [format], must be `png` or `json`.
  String sticker(Snowflake stickerId, {String format = 'png'});

  /// Returns URL to ``/app-assets/710982414301790216/store/[bannerId]``.
  /// With given [format] and [size].
  String stickerPackBanner(Snowflake bannerId, {String format = 'webp', int? size});

  /// Returns URL to ``/team-icons/[teamId]/[teamIconHash]``.
  /// With given [format] and [size].
  String teamIcon(Snowflake teamId, String teamIconHash, {String format = 'webp', int? size});

  /// Returns URL to ``/guild-events/[eventId]/[eventCoverHash]``.
  /// With given [format] and [size].
  String guildEventCoverImage(Snowflake eventId, String eventCoverHash, {String format = 'webp', int? size});

  /// Returns URL to ``/avatar-decorations/[userId]/[decorationHash]``.
  /// With given [size].
  String avatarDecoration(Snowflake userId, String decorationHash, {int? size});
}

class CdnHttpEndpoints implements ICdnHttpEndpoints {
  String _makeAnimatedCdnUrl(ICdnHttpRoute fragment, String hash, {String format = 'webp', int? size, bool animated = true}) {
    final isAnimated = animated && hash.startsWith('a_');

    return _makeCdnUrl(fragment, format: format, size: size, animated: isAnimated);
  }

  String _makeCdnUrl(ICdnHttpRoute fragments, {String format = 'webp', int? size, bool animated = false}) {
    if (!CdnConstants.allowedExtensions.contains(format)) {
      throw Exception('Invalid extension provided, must be one of ${CdnConstants.allowedExtensions.and()}; given: $format');
    }

    if (size != null && !CdnConstants.allowedSizes.contains(size)) {
      throw RangeError('Size out of range: size should be ${CdnConstants.allowedSizes.and()}; given: $size');
    }

    if ((fragments as CdnHttpRoute).path.contains('stickers') && !CdnConstants.allowedExtensionsForSickers.contains(format)) {
      throw Exception('Cannot use other extensions than ${CdnConstants.allowedExtensionsForSickers.and()} for stickers');
    }

    var uri = Uri.https('cdn.${Constants.cdnHost}', '${fragments.path}.${animated ? 'gif' : format}');

    if (size != null) {
      uri = uri.replace(queryParameters: {'size': size.toString()});
    }

    return uri.toString();
  }

  @override
  String appAsset(Snowflake clientId, String assetHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..appAssets(id: clientId.toString())
          ..addHash(hash: assetHash),
        format: format,
        size: size,
      );

  @override
  String appIcon(Snowflake clientId, String iconHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..appIcons(id: clientId.toString())
          ..addHash(hash: iconHash),
        format: format,
        size: size,
      );

  @override
  String avatar(Snowflake id, String avatarHash, {String format = 'webp', int? size, bool animated = true}) => _makeAnimatedCdnUrl(
        ICdnHttpRoute()
          ..avatars(id: id.toString())
          ..addHash(hash: avatarHash),
        avatarHash,
        format: format,
        size: size,
        animated: animated,
      );

  @override
  String banner(Snowflake guildOrUserId, String hash, {String format = 'webp', int? size, bool animated = true}) => _makeAnimatedCdnUrl(
        ICdnHttpRoute()
          ..banners(id: guildOrUserId.toString())
          ..addHash(hash: hash),
        hash,
        format: format,
        size: size,
        animated: animated,
      );

  @override
  String channelIcon(Snowflake channelId, String iconHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..channelIcons(id: channelId.toString())
          ..addHash(hash: iconHash),
        format: format,
        size: size,
      );

  @override
  // TODO: Remove [discriminator] once migration is done?
  String defaultAvatar(int discriminator, int id) {
    final isPomelo = discriminator == 0;
    final index = isPomelo ? (id >> 22) % 6 : discriminator % 5;

    return _makeCdnUrl(
      ICdnHttpRoute()
        ..embed()
        ..avatars(id: index.toString()),
      format: 'png',
    );
  }

  @override
  String discoverySplash(Snowflake guildId, String splashHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..discoverySplashes(id: guildId.toString())
          ..addHash(hash: splashHash),
        format: format,
        size: size,
      );

  @override
  String memberAvatar(Snowflake guildId, Snowflake userId, String avatarHash, {String format = 'webp', int? size, bool animated = true}) => _makeAnimatedCdnUrl(
        ICdnHttpRoute()
          ..guilds(id: guildId.toString())
          ..users(id: userId.toString())
          ..avatars(id: avatarHash),
        avatarHash,
        format: format,
        size: size,
        animated: animated,
      );

  @override
  String emoji(Snowflake emojiId, {String format = 'webp', int? size}) =>
      _makeCdnUrl(ICdnHttpRoute()..emojis(id: emojiId.toString()), format: format, size: size);

  @override
  String icon(Snowflake id, String iconHash, {String format = 'webp', int? size, bool animated = true}) => _makeAnimatedCdnUrl(
        ICdnHttpRoute()
          ..icons(id: id.toString())
          ..addHash(hash: iconHash),
        iconHash,
        format: format,
        size: size,
        animated: animated,
      );

  @override
  String roleIcon(Snowflake roleId, String roleIconHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..roleIcons(id: roleId.toString())
          ..addHash(hash: roleIconHash),
        format: format,
        size: size,
      );

  @override
  String splash(Snowflake guildId, String splashHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..splashes(id: guildId.toString())
          ..addHash(hash: splashHash),
        format: format,
        size: size,
      );
  @override
  String sticker(Snowflake stickerId, {String format = 'png'}) => _makeCdnUrl(
        ICdnHttpRoute()..stickers(id: stickerId.toString()),
        format: format,
      );

  @override
  String stickerPackBanner(Snowflake bannerId, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..appAssets(id: '710982414301790216')
          ..store(id: bannerId.toString()),
        format: format,
        size: size,
      );

  @override
  String teamIcon(Snowflake teamId, String teamIconHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..teamIcons(id: teamId.toString())
          ..addHash(hash: teamIconHash),
        format: format,
        size: size,
      );

  @override
  String guildEventCoverImage(Snowflake eventId, String eventCoverHash, {String format = 'webp', int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..guildEvents(id: eventId.toString())
          ..addHash(hash: eventCoverHash),
        format: format,
        size: size,
      );

  @override
  String avatarDecoration(Snowflake userId, String decorationHash, {int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..avatarDecorations(id: userId.toString())
          ..addHash(hash: decorationHash),
        size: size,
      );
}
