import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template voice_region}
/// A voice region.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/voice#voice-region-object
/// {@endtemplate}
class VoiceRegion with ToStringHelper {
  /// This region's ID.
  final String id;

  /// This region's name.
  final String name;

  /// Whether this voice region is optimal based on the current client's position.
  ///
  /// This will be `true` on at most one region at a time.
  final bool isOptimal;

  /// Whether this voice region is deprecated.
  final bool isDeprecated;

  /// Whether this is a custom voice region.
  final bool isCustom;

  /// {@macro voice_region}
  VoiceRegion({
    required this.id,
    required this.name,
    required this.isOptimal,
    required this.isDeprecated,
    required this.isCustom,
  });
}
