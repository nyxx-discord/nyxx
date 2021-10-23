import 'package:nyxx/src/internal/exceptions/embed_builder_argument_exception.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';

/// Build new instance of author which can be used in [EmbedBuilder]
class EmbedAuthorBuilder extends Builder {
  /// Author name
  String? name;

  /// Author url
  String? url;

  /// Author icon url
  String? iconUrl;

  /// Returns length of embeds author section
  int? get length => name?.length;

  /// Create empty [EmbedAuthorBuilder]
  EmbedAuthorBuilder();

  /// Builds object to Map() instance;
  @override
  RawApiMap build() {
    if (this.name == null || this.name!.isEmpty) {
      throw EmbedBuilderArgumentException("Author name cannot be null or empty");
    }

    if (this.length! > 256) {
      throw EmbedBuilderArgumentException("Author name is too long. (256 characters limit)");
    }

    return <String, dynamic>{"name": name, if (url != null) "url": url, if (iconUrl != null) "icon_url": iconUrl};
  }
}
