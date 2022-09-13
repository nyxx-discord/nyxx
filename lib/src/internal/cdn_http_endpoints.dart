import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/http/http_route.dart';
import 'package:nyxx/src/internal/constants.dart';

abstract class ICdnHttpEndpoints {
  String appAsset(Snowflake clientId, String assetHash, {String? format, int? size});

  String appIcon(Snowflake clientId, String iconHash, {String? format, int? size});

  String avatar(Snowflake id, String avatarHash, {String? format, int? size, bool animatable = false});

  String banner(Snowflake guildOrUserId, String hash, {String? format, int? size, bool animatable = false});

  String channelIcon(Snowflake channelId, String iconHash, {String? format, int? size});

  String defaultAvatar(int discriminator, {int? size});

  String emoji(Snowflake emojiId, {String? format, int? size});

  String discoverySplash(Snowflake guildId, String splashHash, {String? format, int? size});

  String memberAvatar(Snowflake guildId, Snowflake userId, String avatarHash, {String? format, int? size, bool animatable = false});

  String icon(Snowflake id, String iconHash, {String? format, int? size, bool animatable = false});

  String roleIcon(Snowflake roleId, String roleIconHash, {String? format, int? size});

  String splash(Snowflake guildId, String splashHash, {String? format, int? size});

  String sticker(Snowflake stickerId, {String? format = 'png'});

  String stickerPackBanner(Snowflake bannerId, {String? format, int? size});

  String teamIcon(Snowflake teamId, String teamIconHash, {String? format, int? size});

  String guildEventCoverImage(Snowflake eventId, String eventCoverHash, {String? format, int? size});
}

class CdnHttpEndpoints implements ICdnHttpEndpoints {
  String _makeAnimatableCdnUrl(ICdnHttpRoute fragment, String hash, {String? format = 'webp', int? size, bool animatable = false}) {
    if (hash.startsWith('a_') && animatable) {
      animatable = true;
    } else {
      animatable = false;
    }

    return _makeCdnUrl(fragment, format: format, size: size, animatable: animatable);
  }

  String _makeCdnUrl(ICdnHttpRoute fragments, {String? format = 'webp', int? size, bool animatable = false}) {
    format ??= 'webp';
    if (!CdnConstants.allowedExtensions.contains(format)) {
      throw Exception('Invalid extension provided, must be one of ${CdnConstants.allowedExtensions.join(', ')}; given: $format');
    }

    if (size != null && !CdnConstants.allowedSizes.contains(size)) {
      throw RangeError('Size out of range: size should be between ${CdnConstants.allowedSizes.join(', ')}; given: $size');
    }

    if ((fragments as CdnHttpRoute).path.contains('stickers') && !CdnConstants.allowedExtensionsForSickers.contains(format)) {
      throw Exception('Cannot use other extensions than ${CdnConstants.allowedExtensionsForSickers.join(', ')} for stickers');
    }

    var uri = Uri.https('cdn.${Constants.cdnHost}', '${fragments.path}.${animatable ? 'gif' : format}');

    if (size != null) {
      uri = uri.replace(queryParameters: {'size': size.toString()});
    }

    return uri.toString();
  }

  @override
  String appAsset(Snowflake clientId, String assetHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..appAssets(id: clientId.toString())
          ..addHash(hash: assetHash),
        format: format,
        size: size,
      );

  @override
  String appIcon(Snowflake clientId, String iconHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..appIcons(id: clientId.toString())
          ..addHash(hash: iconHash),
        format: format,
        size: size,
      );

  @override
  String avatar(Snowflake id, String avatarHash, {String? format, int? size, bool animatable = false}) => _makeAnimatableCdnUrl(
        ICdnHttpRoute()
          ..avatars(id: id.toString())
          ..addHash(hash: avatarHash),
        avatarHash,
        format: format,
        size: size,
        animatable: animatable,
      );

  @override
  String banner(Snowflake guildOrUserId, String hash, {String? format, int? size, bool animatable = false}) => _makeAnimatableCdnUrl(
        ICdnHttpRoute()
          ..banners(id: guildOrUserId.toString())
          ..addHash(hash: hash),
        hash,
        format: format,
        size: size,
        animatable: animatable,
      );

  @override
  String channelIcon(Snowflake channelId, String iconHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..channelIcons(id: channelId.toString())
          ..addHash(hash: iconHash),
        format: format,
        size: size,
      );

  @override
  String defaultAvatar(int discriminator, {int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..embed()
          ..avatars()
          ..addHash(hash: (discriminator % 5).toString()),
        format: 'png',
        size: size,
      );

  @override
  String discoverySplash(Snowflake guildId, String splashHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..discoverySplashes(id: guildId.toString())
          ..addHash(hash: splashHash),
        format: format,
        size: size,
      );

  @override
  String emoji(Snowflake emojiId, {String? format, int? size}) => _makeCdnUrl(ICdnHttpRoute()..emojis(id: emojiId.toString()), format: format, size: size);

  @override
  String memberAvatar(Snowflake guildId, Snowflake userId, String avatarHash, {String? format, int? size, bool animatable = false}) => _makeAnimatableCdnUrl(
        ICdnHttpRoute()
          ..guilds(id: guildId.toString())
          ..users(id: userId.toString())
          ..avatars()
          ..addHash(hash: avatarHash),
        avatarHash,
        format: format,
        size: size,
        animatable: animatable,
      );

  @override
  String icon(Snowflake id, String iconHash, {String? format, int? size, bool animatable = false}) => _makeAnimatableCdnUrl(
        ICdnHttpRoute()
          ..icons(id: id.toString())
          ..addHash(hash: iconHash),
        iconHash,
        format: format,
        size: size,
        animatable: animatable,
      );

  @override
  String roleIcon(Snowflake roleId, String roleIconHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..roleIcons(id: roleId.toString())
          ..addHash(hash: roleIconHash),
        format: format,
        size: size,
      );

  @override
  String splash(Snowflake guildId, String splashHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..splashes(id: guildId.toString())
          ..addHash(hash: splashHash),
        format: format,
        size: size,
      );
  @override
  String sticker(Snowflake stickerId, {String? format = 'png'}) => _makeCdnUrl(
        ICdnHttpRoute()..stickers(id: stickerId.toString()),
        format: format ?? 'png',
      );

  @override
  String stickerPackBanner(Snowflake bannerId, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..appAssets(id: '710982414301790216')
          ..store(id: bannerId.toString()),
        format: format,
        size: size,
      );

  @override
  String teamIcon(Snowflake teamId, String teamIconHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..teamIcons(id: teamId.toString())
          ..addHash(hash: teamIconHash),
        format: format,
        size: size,
      );

  @override
  String guildEventCoverImage(Snowflake eventId, String eventCoverHash, {String? format, int? size}) => _makeCdnUrl(
        ICdnHttpRoute()
          ..guildEvents(id: eventId.toString())
          ..addHash(hash: eventCoverHash),
        format: format,
        size: size,
      );
}
