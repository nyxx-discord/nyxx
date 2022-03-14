import 'package:nyxx/src/typedefs.dart';

abstract class IEmbedProvider {
  /// The embed provider's name.
  String? get name;

  /// The embed provider's URL.
  String? get url;
}

/// A message embed provider.
class EmbedProvider implements IEmbedProvider {
  /// The embed provider's name.
  @override
  late final String? name;

  /// The embed provider's URL.
  @override
  late final String? url;

  /// Creates an instance of [EmbedProvider]
  EmbedProvider(RawApiMap raw) {
    name = raw["name"] as String?;

    url = raw["url"] as String?;
  }
}
