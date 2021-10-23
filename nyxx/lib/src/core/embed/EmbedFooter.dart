import 'package:nyxx/src/internal/interfaces/Convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/EmbedFooterBuilder.dart';

abstract class IEmbedFooter implements Convertable<EmbedFooterBuilder> {
  /// Text inside footer
  String? get text;

  /// Url of icon which is next to text
  String? get iconUrl;

  /// Proxied url of icon url
  String? get iconProxyUrl;
}

/// Embed's footer. Can contain null elements.
class EmbedFooter implements IEmbedFooter {
  /// Text inside footer
  @override
  late final String? text;

  /// Url of icon which is next to text
  @override
  late final String? iconUrl;

  /// Proxied url of icon url
  @override
  late final String? iconProxyUrl;

  /// Creates an instance of [EmbedFooter]
  EmbedFooter(RawApiMap raw) {
    text = raw["text"] as String?;
    iconUrl = raw["icon_url"] as String?;
    iconProxyUrl = raw["icon_proxy_url"] as String?;
  }

  @override
  EmbedFooterBuilder toBuilder() =>
    EmbedFooterBuilder()
      ..text = this.text
      ..iconUrl = this.iconUrl;
}
