import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/embed_author_builder.dart';

abstract class IEmbedAuthor implements Convertable<EmbedAuthorBuilder> {
  /// Name of embed author
  String? get name;

  /// Url to embed author
  String? get url;

  /// Url to author's url
  String? get iconUrl;

  /// Proxied icon url
  String? get iconProxyUrl;
}

/// Author of embed. Can contain null elements.
class EmbedAuthor implements IEmbedAuthor {
  /// Name of embed author
  @override
  late final String? name;

  /// Url to embed author
  @override
  late final String? url;

  /// Url to author's url
  @override
  late final String? iconUrl;

  /// Proxied icon url
  @override
  late final String? iconProxyUrl;

  /// Creates an instance of [EmbedAuthor]
  EmbedAuthor(RawApiMap raw) {
    name = raw["name"] as String?;
    url = raw["url"] as String?;
    iconUrl = raw["icon_url"] as String?;
    iconProxyUrl = raw["iconProxyUrl"] as String?;
  }

  @override
  String toString() => name ?? "";

  @override
  int get hashCode => url.hashCode * 37 + name.hashCode * 37 + iconUrl.hashCode * 37;

  @override
  bool operator ==(other) => other is EmbedAuthor ? other.url == url && other.name == name && other.iconUrl == iconUrl : false;

  @override
  EmbedAuthorBuilder toBuilder() => EmbedAuthorBuilder()
    ..url = url
    ..name = name
    ..iconUrl = iconUrl;
}
