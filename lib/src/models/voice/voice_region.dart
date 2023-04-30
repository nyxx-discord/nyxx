import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class VoiceRegion with ToStringHelper {
  final String id;

  final String name;

  final bool isOptimal;

  final bool isDeprecated;

  final bool isCustom;

  VoiceRegion({
    required this.id,
    required this.name,
    required this.isOptimal,
    required this.isDeprecated,
    required this.isCustom,
  });
}
