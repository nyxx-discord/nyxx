part of nyxx;

/// A utility to run ._build() on internal functions
class BuilderUtility {
  /// Build the data from an [EmbedBuilder]
  static Map<String, dynamic> buildRawEmbed(EmbedBuilder embed) =>
      embed.build();

  /// Build the data from [AllowedMentions]
  static Map<String, dynamic> buildRawAllowedMentions(AllowedMentions mentions) =>
      mentions.build();

  /// Allows to build any object which implements [Builder]
  static Map<String, dynamic> build<T extends Builder> (T builder) => builder.build();

  /// Allows to build any object which implements [BuilderWithClient]
  static Map<String, dynamic> buildWithClient<T extends BuilderWithClient> (T builder, INyxx client) => builder.build(client);
}
