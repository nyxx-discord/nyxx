part of nyxx;

/// A utility to run .build() on internal functions
class BuilderUtility {
  /// Build the data from an [EmbedBuilder]
  static RawApiMap buildRawEmbed(EmbedBuilder embed) =>
      embed.build();

  /// Build the data from [AllowedMentions]
  static RawApiMap buildRawAllowedMentions(AllowedMentions mentions) =>
      mentions.build();

  /// Allows to build any object which implements [Builder]
  static RawApiMap build<T extends Builder> (T builder) => builder.build();

  /// Allows to build any object which implements [BuilderWithClient]
  static RawApiMap buildWithClient<T extends BuilderWithClient> (T builder, INyxx client) => builder.build(client);
}
