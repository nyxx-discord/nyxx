import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/embed_field_builder.dart';

abstract class IEmbedField implements Convertable<EmbedFieldBuilder> {
  /// Field name
  String get name;

  /// Contents of field (aka value)
  String get content;

  /// Indicates of field is inlined in embed
  bool? get inline;
}

/// Single instance of Embed's field. Can contain null elements.
class EmbedField implements IEmbedField {
  /// Field name
  @override
  late final String name;

  /// Contents of field (aka value)
  @override
  late final String content;

  /// Indicates of field is inlined in embed
  @override
  late final bool? inline;

  /// Creates an instance of [EmbedField]
  EmbedField(RawApiMap raw) {
    name = raw["name"] as String;
    content = raw["value"] as String;
    inline = raw["inline"] as bool?;
  }

  @override
  EmbedFieldBuilder toBuilder() => EmbedFieldBuilder(name, content, inline);
}
