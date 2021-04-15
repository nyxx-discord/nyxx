
/// Collection of regexes for message entities
class Regexes {
  /// Matches user mention
  static final userMentionRegex = RegExp(r"<@!?(\d+)>");

  /// Matches role mention
  static final roleMentionRegex = RegExp(r"<@&(\d+)>");

  /// Matches everyone/here mention
  static final everyoneMentionRegex = RegExp("(@(?:(everyone|here)))");

  /// Matches channel mention
  static final channelMentionRegex = RegExp(r"<#(\d+)>");

  /// Matches guild emoji
  static final emojiMentionRegex = RegExp(r"<(a?):(\w+):(\d+)>");
}
