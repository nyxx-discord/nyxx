import "dart:async";

import "package:nyxx/nyxx.dart" show GuildTextChannel, Message, Nyxx, Role, Snowflake;

import "Regexes.dart" show Regexes;

/// Possible types of tag handling for [MessageResolver]
enum TagHandling {
  /// Ignores tag handling completely - leaves content as is.
  ignore,
  /// Removes tag completely.
  remove,
  /// Returns name of tag, eg. `<@932489234> -> @l7ssha`
  name,
  /// Returns name of tag without mention prefix, eg. `<@932489234> -> l7ssha`
  nameNoPrefix,
  /// Returns name of the tag with full possible data, eg. `<@932489234> -> @l7ssha#6712`
  fullName,
  /// Returns name of the tag with full possible data without mention prefix, eg. `<@932489234> -> l7ssha#6712`
  fullNameNoPrefix,
  /// Sanitizes tag to form that client wont treat it as valid tag
  sanitize
}

/// Extends [Message] class with [MessageResolver]
extension MessageResolverExtension on Message {
  /// Resolves raw message content to human readable string.
  /// Allows to set what to do with particular parts of message.
  /// Each mention, channel reference and emoji can be resolved by [TagHandling]
  FutureOr<String> resolveContent( {
    TagHandling userTagHandling = TagHandling.sanitize,
    TagHandling roleTagHandling = TagHandling.sanitize,
    TagHandling everyoneTagHandling = TagHandling.sanitize,
    TagHandling channelTagHandling = TagHandling.sanitize,
    TagHandling emojiTagHandling = TagHandling.sanitize
  }) {
    if(this.content.isEmpty) {
      return "";
    }

    return MessageResolver(this.client,
      userTagHandling: userTagHandling,
      roleTagHandling: roleTagHandling,
      everyoneTagHandling: everyoneTagHandling,
      channelTagHandling: channelTagHandling,
      emojiTagHandling: everyoneTagHandling).resolve(this.content);
  }
}

/// Allows to return custom messages in case of missing entities when resolving message content.
/// [entityType] could be either `role`, `channel` or `user`.
typedef MissingEntityHandler = FutureOr<String> Function(String entityType);

/// Resolves raw message content to human readable string.
/// Allows to set what to do with particular parts of message.
/// Each mention, channel reference and emoji can be resolved by [TagHandling]
class MessageResolver {
  final Nyxx _client;
  static const String _whiteSpaceCharacter = "‎";

  /// Handles resolving of user mentions
  final TagHandling userTagHandling;

  /// Handles resolving of role mentions
  final TagHandling roleTagHandling;

  /// Handles resolving of everyone/here mentions
  final TagHandling everyoneTagHandling;

  /// Handles resolving of channels mentions
  final TagHandling channelTagHandling;

  /// Handles resolving of guild emojis
  final TagHandling emojiTagHandling;

  /// Handles what will be returned in case if entity cannot be resolved
  late final MissingEntityHandler missingEntityHandler;

  /// Create message resolver with given options
  MessageResolver(this._client, {
    this.userTagHandling = TagHandling.sanitize,
    this.roleTagHandling = TagHandling.sanitize,
    this.everyoneTagHandling = TagHandling.sanitize,
    this.channelTagHandling = TagHandling.sanitize,
    this.emojiTagHandling = TagHandling.sanitize,
    MissingEntityHandler? missingEntityHandler
  }) {
    if (missingEntityHandler == null) {
      this.missingEntityHandler = _defaultMissingEntityHandler;
    } else {
      this.missingEntityHandler = missingEntityHandler;
    }
  }

  /// Create message resolver with tag handlers set to [tagHandling].
  factory MessageResolver.uniform(Nyxx client, TagHandling tagHandling) =>
      MessageResolver(client,
        userTagHandling: tagHandling,
        roleTagHandling: tagHandling,
        everyoneTagHandling: tagHandling,
        channelTagHandling: tagHandling,
        emojiTagHandling: tagHandling
    );

  /// Resolves raw [messageContent] into human readable form.
  Future<String> resolve(String messageContent) async {
    if (messageContent.trim().isEmpty) {
      return "";
    }

    final messageParts = messageContent.split(" ");
    final outputBuffer = StringBuffer();

    for(final part in messageParts) {
      outputBuffer.write(" ");

      final userMatch = Regexes.userMentionRegex.firstMatch(part);
      if (userMatch != null) {
        outputBuffer.write(await this._resoleUserMention(userMatch, part));
        continue;
      }

      final roleMatch = Regexes.roleMentionRegex.firstMatch(part);
      if (roleMatch != null) {
        outputBuffer.write(await this._resolveRoleMention(roleMatch, part));
        continue;
      }

      final everyoneMatch = Regexes.everyoneMentionRegex.firstMatch(part);
      if (everyoneMatch != null) {
        outputBuffer.write(await this._resolveEveryone(everyoneMatch, part));
        continue;
      }

      final channelMatch = Regexes.channelMentionRegex.firstMatch(part);
      if (channelMatch != null) {
        outputBuffer.write(await this._resolveChannel(channelMatch, part));
        continue;
      }

      final emojiMatch = Regexes.emojiMentionRegex.firstMatch(part);
      if (emojiMatch != null) {
        outputBuffer.write(await this._resolveEmoji(emojiMatch, part));
        continue;
      }
      
      outputBuffer.write(part);
    }
    
    return outputBuffer.toString().trim();
  }

  FutureOr<String> _resolveEmoji(RegExpMatch match, String content) async {
    if (emojiTagHandling == TagHandling.ignore) {
      return content;
    }

    if (emojiTagHandling == TagHandling.remove) {
      return "";
    }

    if (emojiTagHandling == TagHandling.sanitize) {
      // TODO: check how to escape emoji properly
      return "<${match.group(1)}:${match.group(2)}$_whiteSpaceCharacter:$_whiteSpaceCharacter${match.group(3)}>";
    }

    if (emojiTagHandling == TagHandling.name || emojiTagHandling == TagHandling.fullName) {
      return ":${match.group(2)}:";
    }

    if (emojiTagHandling == TagHandling.nameNoPrefix || emojiTagHandling == TagHandling.fullNameNoPrefix) {
      return match.group(2).toString();
    }

    return content;
  }

  FutureOr<String> _resolveChannel(RegExpMatch match, String content) async {
    if (channelTagHandling == TagHandling.ignore) {
      return content;
    }

    if (channelTagHandling == TagHandling.remove) {
      return "";
    }

    if (channelTagHandling == TagHandling.sanitize) {
      return "<#$_whiteSpaceCharacter${match.group(1)}>";
    }
    
    final channel = _client.channels.values.firstWhere((ch) => ch is GuildTextChannel && ch.id == match.group(1)) as GuildTextChannel?;

    if (channelTagHandling == TagHandling.name || channelTagHandling == TagHandling.fullName) {
      return channel != null ? "#${channel.name}" : this.missingEntityHandler("channel");
    }

    if (channelTagHandling == TagHandling.nameNoPrefix || channelTagHandling == TagHandling.fullNameNoPrefix) {
      return channel != null ? channel.name : this.missingEntityHandler("channel");
    }
    
    return content;
  }
  
  FutureOr<String> _resolveEveryone(RegExpMatch match, String content) async {
    if (roleTagHandling == TagHandling.remove) {
      return "";
    }

    if (roleTagHandling == TagHandling.sanitize) {
      return "@$_whiteSpaceCharacter${match.group(1)}";
    }

    return content;
  }

  FutureOr<String> _resolveRoleMention(RegExpMatch match, String content) async {
    if (roleTagHandling == TagHandling.ignore) {
      return content;
    }

    if (roleTagHandling == TagHandling.remove) {
      return "";
    }

    if (roleTagHandling == TagHandling.sanitize) {
      return "<@&$_whiteSpaceCharacter${match.group(1)}>";
    }

    final role = _client.guilds.values
        .map((e) => e.roles.values)
        .expand((element) => element)
        .firstWhere((element) => element.id == Snowflake(match.group(1))) as Role?;

    if (roleTagHandling == TagHandling.name || roleTagHandling == TagHandling.fullName) {
      return role != null ? "@${role.name}" : this.missingEntityHandler("role");
    }

    if (roleTagHandling == TagHandling.nameNoPrefix || roleTagHandling == TagHandling.fullNameNoPrefix) {
      return role != null ? role.name : this.missingEntityHandler("role");
    }

    return content;
  }

  FutureOr<String> _resoleUserMention(RegExpMatch match, String content) async {
    if (userTagHandling == TagHandling.ignore) {
      return content;
    }

    if (userTagHandling == TagHandling.remove) {
      return "";
    }

    if (userTagHandling == TagHandling.sanitize) {
      return "<@$_whiteSpaceCharacter${match.group(1)}>";
    }

    final user = await _client.getUser(Snowflake(match.group(1)));

    if (userTagHandling == TagHandling.name) {
      return user != null ? "@${user.username}" : this.missingEntityHandler("user");
    }

    if (userTagHandling == TagHandling.nameNoPrefix) {
      return user != null ? user.username : this.missingEntityHandler("user");
    }

    if (userTagHandling == TagHandling.fullName) {
      return user != null ? "@${user.tag}" : this.missingEntityHandler("user");
    }

    if (userTagHandling == TagHandling.fullNameNoPrefix) {
      return user != null ? "${user.tag}" : this.missingEntityHandler("user");
    }

    return "";
  }
}

FutureOr<String> _defaultMissingEntityHandler(String entityType) {
  switch (entityType) {
    case "user":
      return "[Could not get user]";
    case "role":
      return "[Could not get role]";
    case "channel":
      return "[Could not get channel]";
    default:
      return "";
  }
}