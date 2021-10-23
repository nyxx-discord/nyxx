import 'package:nyxx/src/internal/interfaces/Convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/EmbedAuthorBuilder.dart';

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
  String? name;

  /// Url to embed author
  @override
  String? url;

  /// Url to author's url
  @override
  String? iconUrl;

  /// Proxied icon url
  @override
  String? iconProxyUrl;

  /// Creates an instance of [EmbedAuthor]
  EmbedAuthor(RawApiMap raw) {
    this.name = raw["name"] as String?;
    this.url = raw["url"] as String?;
    this.iconUrl = raw["icon_url"] as String?;
    this.iconProxyUrl = raw["iconProxyUrl"] as String?;
  }

  @override
  String toString() => name ?? "";

  @override
  int get hashCode => url.hashCode * 37 + name.hashCode * 37 + iconUrl.hashCode * 37;

  @override
  bool operator ==(other) =>
      other is EmbedAuthor ? other.url == this.url && other.name == this.name && other.iconUrl == this.iconUrl : false;

  @override
  EmbedAuthorBuilder toBuilder() =>
    EmbedAuthorBuilder()
      ..url = this.url
      ..name = this.name
      ..iconUrl = this.iconUrl;
}
