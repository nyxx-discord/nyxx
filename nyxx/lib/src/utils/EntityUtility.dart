part of nyxx;

/// Entity Utility is a Utility that lets you create Entities from outside of the nyxx project. Typically used in nyxx.* projects.
/// An example getting a user is below:
/// ```dart
/// void main() {
///     var bot = Nyxx("TOKEN");
///     Map<String, dynamic> json = /* JSON from the API */
///     User user = EntityUtility.createUser(bot, json);
/// }
/// ```
class EntityUtility {
  /// Creates a User object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     User user = EntityUtility.createUser(bot, json);
  /// }
  /// ```
  User createUser(
    Nyxx client,
    Map<String, dynamic> json,
  ) =>
      User._new(
        client,
        json,
      );

  /// Creates a Guild object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     Guild guild = EntityUtility.createGuild(bot, json);
  /// }
  /// ```
  Guild createGuild(
    Nyxx client,
    Map<String, dynamic> json,
  ) =>
      Guild._new(
        client,
        json,
      );

  /// Creates a Role object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     Role role = EntityUtility.createRole(bot, json, Snowflake("81384788765712384"));
  /// }
  /// ```
  Role createRole(
    Nyxx client,
    Snowflake guildId,
    Map<String, dynamic> json,
  ) =>
      Role._new(
        client,
        json,
        guildId,
      );

  /// Creates a CategoryGuildChannel object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     CategoryGuildChannel category = EntityUtility.createCategoryGuildChannel(bot, json, Snowflake("81384788765712384"));
  /// }
  /// ```
  CategoryGuildChannel createCategoryGuildChannel(
    Nyxx client,
    Snowflake guildId,
    Map<String, dynamic> json,
  ) =>
      CategoryGuildChannel._new(
        client,
        json,
        guildId,
      );

  /// Creates a VoiceGuildChannel object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     VoiceGuildChannel voiceChannel = EntityUtility.createVoiceGuildChannel(bot, json, Snowflake("81384788765712384"));
  /// }
  /// ```
  VoiceGuildChannel createVoiceGuildChannel(
    Nyxx client,
    Snowflake guildId,
    Map<String, dynamic> json,
  ) =>
      VoiceGuildChannel._new(
        client,
        json,
        guildId,
      );

  /// Creates a Guild object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     TextGuildChannel textChannel = EntityUtility.createTextGuildChannel(bot, json, Snowflake("81384788765712384"));
  /// }
  /// ```
  TextGuildChannel createTextGuildChannel(
    Nyxx client,
    Snowflake guildId,
    Map<String, dynamic> json,
  ) =>
      TextGuildChannel._new(
        client,
        json,
        guildId,
      );

  /// Creates a Guild object, can be used for other classes where you have correct JSON data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> json = /* JSON from the API */
  ///     DMChannel dmChannel = EntityUtility.createDMChannel(bot, json);
  /// }
  /// ```
  DMChannel createDMChannel(
    Nyxx client,
    Map<String, dynamic> json,
  ) =>
      DMChannel._new(
        client,
        json,
      );
}
