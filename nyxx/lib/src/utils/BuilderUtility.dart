part of nyxx;

class BuilderUtility {
  static Map<String, dynamic> buildRawEmbed(EmbedBuilder embed) =>
      embed._build();

  static Map<String, dynamic> buildRawAllowedMentions(
          AllowedMentions mentions) =>
      mentions._build();
}
