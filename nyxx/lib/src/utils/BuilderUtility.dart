part of nyxx;

/// A utility to run ._build() on internal functions
class BuilderUtility {
  /// Build the data from an [EmbedBuilder]
  static Map<String, dynamic> buildRawEmbed(EmbedBuilder embed) =>
      embed._build();

  /// Build the data from [AllowedMentions]
  static Map<String, dynamic> buildRawAllowedMentions(AllowedMentions mentions) =>
      mentions._build();

  static Map<String, dynamic> build<T extends Builder> (T builder) => builder._build();

  static Map<String, dynamic> buildWithClient<T extends BuilderWithClient> (T builder, INyxx client) => builder.build(client);
}
