/// @docImport 'package:nyxx/nyxx.dart';
library;

import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// The result of searching for messages within a [Guild].
///
/// {@category models}
class MessageSearchResult with ToStringHelper {
  /// Whether the guild is undergoing a deep historical indexing operation.
  final bool doingDeepHistoricalIndex;

  /// The number of documents that have been indexed during the current index operation, if any.
  final int? indexedDocumentCount;

  /// The total number of results that match the query.
  final int totalResults;

  /// The messages that match the query.
  final List<Message> messages;

  /// The threads that contain the returned messages.
  final List<Thread> threads;

  /// A thread member object for each returned thread the current user has joined.
  final List<ThreadMember> threadMembers;

  /// @nodoc
  MessageSearchResult({
    required this.doingDeepHistoricalIndex,
    required this.indexedDocumentCount,
    required this.totalResults,
    required this.messages,
    required this.threads,
    required this.threadMembers,
  });
}

/// The type of a message author.
enum MessageAuthorType {
  user._('user'),
  bot._('bot'),
  webhook._('webhook');

  final String type;

  const MessageAuthorType._(this.type);
}

/// Content that may be present in a message.
enum MessageContentType {
  image._('image'),
  sound._('sound'),
  video._('video'),
  file._('file'),
  sticker._('sticker'),
  embed._('embed'),
  link._('link'),
  poll._('poll'),
  snapshot._('snapshot');

  final String type;
  const MessageContentType._(this.type);
}

/// The type of an [Embed] in a message search.
enum SearchEmbedType {
  image._('image'),
  video._('video'),
  gif._('gif'),
  sound._('sound'),
  article._('article');

  final String type;

  const SearchEmbedType._(this.type);
}

/// The order in which messages are returned by a message search operation.
enum MessageSearchOrder {
  timestamp._('timestamp'),
  relevance._('relevance');

  final String order;

  const MessageSearchOrder._(this.order);
}
