import 'dart:async';

import 'package:nyxx/src/events/ChannelEvents.dart';
import 'package:nyxx/src/events/DisconnectEvent.dart';
import 'package:nyxx/src/events/GuildEvents.dart';
import 'package:nyxx/src/events/HttpEvents.dart';
import 'package:nyxx/src/events/InviteEvents.dart';
import 'package:nyxx/src/events/MessageEvents.dart';
import 'package:nyxx/src/events/PresenceUpdateEvent.dart';
import 'package:nyxx/src/events/RatelimitEvent.dart';
import 'package:nyxx/src/events/ReadyEvent.dart';
import 'package:nyxx/src/events/ThreadCreateEvent.dart';
import 'package:nyxx/src/events/ThreadDeletedEvent.dart';
import 'package:nyxx/src/events/ThreadMembersUpdateEvent.dart';
import 'package:nyxx/src/events/TypingEvent.dart';
import 'package:nyxx/src/events/UserUpdateEvent.dart';
import 'package:nyxx/src/events/VoiceServerUpdateEvent.dart';
import 'package:nyxx/src/events/VoiceStateUpdateEvent.dart';
import 'package:nyxx/src/internal/interfaces/Disposable.dart';

abstract class IRestEventController implements Disposable {
  /// Emitted when a successful HTTP response is received.
  Stream<IHttpResponseEvent> get onHttpResponse;

  /// Emitted when a HTTP request failed.
  Stream<IHttpErrorEvent> get onHttpError;

  /// Sent when the client is rate limited, either by the rate limit handler itself,
  /// or when a 429 is received.
  Stream<IRatelimitEvent> get onRateLimited;
}

class RestEventController extends IRestEventController {
  /// Emitted when a successful HTTP response is received.
  late final StreamController<IHttpResponseEvent> onHttpResponseController;

  /// Emitted when a HTTP request failed.
  late final StreamController<IHttpErrorEvent> onHttpErrorController;

  /// Sent when the client is rate limited, either by the rate limit handler itself,
  /// or when a 429 is received.
  late final StreamController<IRatelimitEvent> onRateLimitedController;

  /// Emitted when a successful HTTP response is received.
  @override
  late final Stream<IHttpResponseEvent> onHttpResponse;

  /// Emitted when a HTTP request failed.
  @override
  late final Stream<IHttpErrorEvent> onHttpError;

  /// Sent when the client is rate limited, either by the rate limit handler itself,
  /// or when a 429 is received.
  @override
  late final Stream<IRatelimitEvent> onRateLimited;

  /// Creats an instance of [RestEventController]
  RestEventController() {
    this.onHttpErrorController = StreamController.broadcast();
    this.onHttpError = onHttpErrorController.stream;

    this.onHttpResponseController = StreamController.broadcast();
    this.onHttpResponse = onHttpResponseController.stream;

    this.onRateLimitedController = StreamController.broadcast();
    this.onRateLimited = onRateLimitedController.stream;
  }

  @override
  Future<void> dispose() async {
    await this.onRateLimitedController.close();
    await this.onHttpResponseController.close();
    await this.onRateLimitedController.close();
  }
}

abstract class IWebsocketEventController implements IRestEventController {
  /// Emitted when a shard is disconnected from the websocket.
  Stream<IDisconnectEvent> get onDisconnect;

  /// Emitted when the client is ready. Should be sent only once.
  Stream<IReadyEvent> get onReady;

  /// Emitted when a message is received. It includes private messages.
  Stream<IMessageReceivedEvent> get onMessageReceived;

  /// Emitted when private message is received.
  Stream<IMessageReceivedEvent> get onDmReceived;

  /// Emitted when channel"s pins are updated.
  Stream<IChannelPinsUpdateEvent> get onChannelPinsUpdate;

  /// Emitted when guild"s emojis are changed.
  Stream<IGuildEmojisUpdateEvent> get onGuildEmojisUpdate;

  /// Emitted when a message is edited. Old message can be null if isn"t cached.
  Stream<IMessageUpdateEvent> get onMessageUpdate;

  /// Emitted when a message is deleted.
  Stream<IMessageDeleteEvent> get onMessageDelete;

  /// Emitted when a channel is created.
  Stream<IChannelCreateEvent> get onChannelCreate;

  /// Emitted when a channel is updated.
  Stream<IChannelUpdateEvent> get onChannelUpdate;

  /// Emitted when a channel is deleted.
  Stream<IChannelDeleteEvent> get onChannelDelete;

  /// Emitted when a member is banned.
  Stream<IGuildBanAddEvent> get onGuildBanAdd;

  /// Emitted when a user is unbanned.
  Stream<IGuildBanRemoveEvent> get onGuildBanRemove;

  /// Emitted when the client joins a guild.
  Stream<IGuildCreateEvent> get onGuildCreate;

  /// Emitted when a guild is updated.
  Stream<IGuildUpdateEvent> get onGuildUpdate;

  /// Emitted when the client leaves a guild.
  Stream<IGuildDeleteEvent> get onGuildDelete;

  /// Emitted when a member joins a guild.
  Stream<IGuildMemberAddEvent> get onGuildMemberAdd;

  /// Emitted when a member is updated.
  Stream<IGuildMemberUpdateEvent> get onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  Stream<IGuildMemberRemoveEvent> get onGuildMemberRemove;

  /// Emitted when a member"s presence is changed.
  Stream<IPresenceUpdateEvent> get onPresenceUpdate;

  /// Emitted when a user starts typing.
  Stream<ITypingEvent> get onTyping;

  /// Emitted when a role is created.
  Stream<IRoleCreateEvent> get onRoleCreate;

  /// Emitted when a role is updated.
  Stream<IRoleUpdateEvent> get onRoleUpdate;

  /// Emitted when a role is deleted.
  Stream<IRoleDeleteEvent> get onRoleDelete;

  /// Emitted when many messages are deleted at once
  Stream<IMessageDeleteBulkEvent> get onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  Stream<IMessageReactionEvent> get onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  Stream<IMessageReactionEvent> get onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  Stream<IMessageReactionsRemovedEvent> get onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channel.
  Stream<IVoiceStateUpdateEvent> get onVoiceStateUpdate;

  /// Emitted when a guild"s voice server is updated.
  /// This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  Stream<IVoiceServerUpdateEvent> get onVoiceServerUpdate;

  /// Emitted when user was updated
  Stream<IUserUpdateEvent> get onUserUpdate;

  /// Emitted when bot is mentioned
  Stream<IMessageReceivedEvent> get onSelfMention;

  /// Emitted when invite is created
  Stream<IInviteCreatedEvent> get onInviteCreated;

  /// Emitted when invite is deleted
  Stream<IInviteDeletedEvent> get onInviteDeleted;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  Stream<IMessageReactionRemoveEmojiEvent> get onMessageReactionRemoveEmoji;

  /// Emitted when a thread is created
  Stream<IThreadCreateEvent> get onThreadCreated;

  /// Fired when a thread has a member added/removed
  Stream<IThreadMembersUpdateEvent> get onThreadMembersUpdate;

  /// Fired when a thread gets deleted
  Stream<IThreadDeletedEvent> get onThreadDelete;

  /// Emitted when stage channel instance is created
  Stream<IStageInstanceEvent> get onStageInstanceCreate;

  /// Emitted when stage channel instance is updated
  Stream<IStageInstanceEvent> get onStageInstanceUpdate;

  /// Emitted when stage channel instance is deleted
  Stream<IStageInstanceEvent> get onStageInstanceDelete;

  /// Emitted when stage channel instance is deleted
  Stream<IGuildStickerUpdate> get onGuildStickersUpdate;
}

/// A controller for all events.
class WebsocketEventController extends RestEventController implements IWebsocketEventController {
  /// Emitted when a shard is disconnected from the websocket.
  late final StreamController<IDisconnectEvent> onDisconnectController;

  /// Emitted when the client is ready.
  late final StreamController<IReadyEvent> onReadyController;

  /// Emitted when a message is received.
  late final StreamController<IMessageReceivedEvent> onMessageReceivedController;

  /// Emitted when channel's pins are updated.
  late final StreamController<IChannelPinsUpdateEvent> onChannelPinsUpdateController;

  /// Emitted when guild's emojis are changed.
  late final StreamController<IGuildEmojisUpdateEvent> onGuildEmojisUpdateController;

  /// Emitted when a message is edited.
  late final StreamController<IMessageUpdateEvent> onMessageUpdateController;

  /// Emitted when a message is edited.
  late final StreamController<IMessageDeleteEvent> onMessageDeleteController;

  /// Emitted when a channel is created.
  late final StreamController<IChannelCreateEvent> onChannelCreateController;

  /// Emitted when a channel is updated.
  late final StreamController<IChannelUpdateEvent> onChannelUpdateController;

  /// Emitted when a channel is deleted.
  late final StreamController<IChannelDeleteEvent> onChannelDeleteController;

  /// Emitted when a member is banned.
  late final StreamController<IGuildBanAddEvent> onGuildBanAddController;

  /// Emitted when a user is unbanned.
  late final StreamController<IGuildBanRemoveEvent> onGuildBanRemoveController;

  /// Emitted when the client joins a guild.
  late final StreamController<IGuildCreateEvent> onGuildCreateController;

  /// Emitted when a guild is updated..
  late final StreamController<IGuildUpdateEvent> onGuildUpdateController;

  /// Emitted when the client leaves a guild.
  late final StreamController<IGuildDeleteEvent> onGuildDeleteController;

  /// Emitted when a member joins a guild.
  late final StreamController<IGuildMemberAddEvent> onGuildMemberAddController;

  /// Emitted when a member is updated.
  late final StreamController<IGuildMemberUpdateEvent> onGuildMemberUpdateController;

  /// Emitted when a user leaves a guild.
  late final StreamController<IGuildMemberRemoveEvent> onGuildMemberRemoveController;

  /// Emitted when a member's presence is updated.
  late final StreamController<IPresenceUpdateEvent> onPresenceUpdateController;

  /// Emitted when a user starts typing.
  late final StreamController<ITypingEvent> onTypingController;

  /// Emitted when a role is updated.
  late final StreamController<IRoleCreateEvent> onRoleCreateController;

  /// Emitted when a role is created.
  late final StreamController<IRoleUpdateEvent> onRoleUpdateController;

  /// Emitted when a role is deleted.
  late final StreamController<IRoleDeleteEvent> onRoleDeleteController;

  /// Emitted when many messages are deleted at once
  late final StreamController<IMessageDeleteBulkEvent> onMessageDeleteBulkController;

  /// Emitted when a user adds a reaction to a message.
  late final StreamController<IMessageReactionEvent> onMessageReactionAddedController;

  /// Emitted when a user deletes a reaction to a message.
  late final StreamController<IMessageReactionEvent> onMessageReactionRemoveController;

  /// Emitted when a user explicitly removes all reactions from a message.
  late final StreamController<IMessageReactionsRemovedEvent> onMessageReactionsRemovedController;

  /// Emitted when someone joins/leaves/moves voice channels.
  late final StreamController<IVoiceStateUpdateEvent> onVoiceStateUpdateController;

  /// Emitted when a guild's voice server is updated. This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  late final StreamController<IVoiceServerUpdateEvent> onVoiceServerUpdateController;

  /// Emitted when user was updated
  late final StreamController<IUserUpdateEvent> onUserUpdateController;

  /// Emitted when invite is creating
  late final StreamController<IInviteCreatedEvent> onInviteCreatedController;

  /// Emitted when invite is deleted
  late final StreamController<IInviteDeletedEvent> onInviteDeleteController;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  late final StreamController<IMessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmojiController;

  /// Emitted when a thread is created
  late final StreamController<IThreadCreateEvent> onThreadCreatedController;

  /// Fired when a thread has a member added/removed
  late final StreamController<IThreadMembersUpdateEvent> onThreadMembersUpdateController;

  /// Fired when a thread gets deleted
  late final StreamController<IThreadDeletedEvent> onThreadDeleteController;
  /// Emitted when stage channel instance is created
  late final StreamController<IStageInstanceEvent> onStageInstanceCreateController;

  /// Emitted when stage channel instance is updated
  late final StreamController<IStageInstanceEvent> onStageInstanceUpdateController;

  /// Emitted when stage channel instance is deleted
  late final StreamController<IStageInstanceEvent> onStageInstanceDeleteController;

  /// Emitted when guild stickers are update
  late final StreamController<IGuildStickerUpdate> onGuildStickersUpdateController;

  /// Emitted when a shard is disconnected from the websocket.
  late final Stream<IDisconnectEvent> onDisconnect;

  /// Emitted when the client is ready. Should be sent only once.
  late final Stream<IReadyEvent> onReady;

  /// Emitted when a message is received. It includes private messages.
  late final Stream<IMessageReceivedEvent> onMessageReceived;

  /// Emitted when private message is received.
  late final Stream<IMessageReceivedEvent> onDmReceived;

  /// Emitted when channel"s pins are updated.
  late final Stream<IChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild"s emojis are changed.
  late final Stream<IGuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited. Old message can be null if isn"t cached.
  late final Stream<IMessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is deleted.
  late final Stream<IMessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  late final Stream<IChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  late final Stream<IChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  late final Stream<IChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  late final Stream<IGuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  late final Stream<IGuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  late final Stream<IGuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated.
  late final Stream<IGuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  late final Stream<IGuildDeleteEvent> onGuildDelete;

  /// Emitted when a member joins a guild.
  late final Stream<IGuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  late final Stream<IGuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  late final Stream<IGuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member"s presence is changed.
  late final Stream<IPresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  late final Stream<ITypingEvent> onTyping;

  /// Emitted when a role is created.
  late final Stream<IRoleCreateEvent> onRoleCreate;

  /// Emitted when a role is updated.
  late final Stream<IRoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  late final Stream<IRoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  late final Stream<IMessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  late final Stream<IMessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  late final Stream<IMessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  late final Stream<IMessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channel.
  late final Stream<IVoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild"s voice server is updated.
  /// This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  late final Stream<IVoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when user was updated
  late final Stream<IUserUpdateEvent> onUserUpdate;

  /// Emitted when bot is mentioned
  late final Stream<IMessageReceivedEvent> onSelfMention;

  /// Emitted when invite is created
  late final Stream<IInviteCreatedEvent> onInviteCreated;

  /// Emitted when invite is deleted
  late final Stream<IInviteDeletedEvent> onInviteDeleted;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  late final Stream<IMessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmoji;

  /// Emitted when a thread is created
  late final Stream<IThreadCreateEvent> onThreadCreated;

  /// Fired when a thread has a member added/removed
  late final Stream<IThreadMembersUpdateEvent> onThreadMembersUpdate;

  /// Fired when a thread gets deleted
  late final Stream<IThreadDeletedEvent> onThreadDelete;

  /// Emitted when stage channel instance is created
  late final Stream<IStageInstanceEvent> onStageInstanceCreate;

  /// Emitted when stage channel instance is updated
  late final Stream<IStageInstanceEvent> onStageInstanceUpdate;

  /// Emitted when stage channel instance is deleted
  late final Stream<IStageInstanceEvent> onStageInstanceDelete;

  /// Emitted when stage channel instance is deleted
  late final Stream<IGuildStickerUpdate> onGuildStickersUpdate;

  /// Makes a new `EventController`.
  WebsocketEventController(): super() {
    this.onDisconnectController = StreamController.broadcast();
    this.onDisconnect = this.onDisconnectController.stream;

    this.onReadyController = StreamController.broadcast();
    this.onReady = this.onReadyController.stream;

    this.onMessageReceivedController = StreamController.broadcast();
    this.onMessageReceived = this.onMessageReceivedController.stream;

    this.onMessageUpdateController = StreamController.broadcast();
    this.onMessageUpdate = this.onMessageUpdateController.stream;

    this.onMessageDeleteController = StreamController.broadcast();
    this.onMessageDelete = this.onMessageDeleteController.stream;

    this.onChannelCreateController = StreamController.broadcast();
    this.onChannelCreate = this.onChannelCreateController.stream;

    this.onChannelUpdateController = StreamController.broadcast();
    this.onChannelUpdate = this.onChannelUpdateController.stream;

    this.onChannelDeleteController = StreamController.broadcast();
    this.onChannelDelete = this.onChannelDeleteController.stream;

    this.onGuildBanAddController = StreamController.broadcast();
    this.onGuildBanAdd = this.onGuildBanAddController.stream;

    this.onGuildBanRemoveController = StreamController.broadcast();
    this.onGuildBanRemove = this.onGuildBanRemoveController.stream;

    this.onGuildCreateController = StreamController.broadcast();
    this.onGuildCreate = this.onGuildCreateController.stream;

    this.onGuildUpdateController = StreamController.broadcast();
    this.onGuildUpdate = this.onGuildUpdateController.stream;

    this.onGuildDeleteController = StreamController.broadcast();
    this.onGuildDelete = this.onGuildDeleteController.stream;

    this.onGuildMemberAddController = StreamController.broadcast();
    this.onGuildMemberAdd = this.onGuildMemberAddController.stream;

    this.onGuildMemberUpdateController = StreamController.broadcast();
    this.onGuildMemberUpdate = this.onGuildMemberUpdateController.stream;

    this.onGuildMemberRemoveController = StreamController.broadcast();
    this.onGuildMemberRemove = this.onGuildMemberRemoveController.stream;

    this.onPresenceUpdateController = StreamController.broadcast();
    this.onPresenceUpdate = this.onPresenceUpdateController.stream;

    this.onTypingController = StreamController.broadcast();
    this.onTyping = this.onTypingController.stream;

    this.onRoleCreateController = StreamController.broadcast();
    this.onRoleCreate = this.onRoleCreateController.stream;

    this.onRoleUpdateController = StreamController.broadcast();
    this.onRoleUpdate = this.onRoleUpdateController.stream;

    this.onRoleDeleteController = StreamController.broadcast();
    this.onRoleDelete = this.onRoleDeleteController.stream;

    this.onChannelPinsUpdateController = StreamController.broadcast();
    this.onChannelPinsUpdate = this.onChannelPinsUpdateController.stream;

    this.onGuildEmojisUpdateController = StreamController.broadcast();
    this.onGuildEmojisUpdate = this.onGuildEmojisUpdateController.stream;

    this.onMessageDeleteBulkController = StreamController.broadcast();
    this.onMessageDeleteBulk = this.onMessageDeleteBulkController.stream;

    this.onMessageReactionAddedController = StreamController.broadcast();
    this.onMessageReactionAdded = this.onMessageReactionAddedController.stream;

    this.onMessageReactionRemoveController = StreamController.broadcast();
    this.onMessageReactionRemove = this.onMessageReactionRemoveController.stream;

    this.onMessageReactionsRemovedController = StreamController.broadcast();
    this.onMessageReactionsRemoved = this.onMessageReactionsRemovedController.stream;

    this.onVoiceStateUpdateController = StreamController.broadcast();
    this.onVoiceStateUpdate = this.onVoiceStateUpdateController.stream;

    this.onVoiceServerUpdateController = StreamController.broadcast();
    this.onVoiceServerUpdate = this.onVoiceServerUpdateController.stream;

    this.onUserUpdateController = StreamController.broadcast();
    this.onUserUpdate = this.onUserUpdateController.stream;

    this.onInviteCreatedController = StreamController.broadcast();
    this.onInviteCreated = this.onInviteCreatedController.stream;

    this.onInviteDeleteController = StreamController.broadcast();
    this.onInviteDeleted = this.onInviteDeleteController.stream;

    this.onMessageReactionRemoveEmojiController = StreamController.broadcast();
    this.onMessageReactionRemoveEmoji = this.onMessageReactionRemoveEmojiController.stream;

    this.onThreadCreatedController = StreamController.broadcast();
    this.onThreadCreated = this.onThreadCreatedController.stream;

    this.onThreadMembersUpdateController = StreamController.broadcast();
    this.onThreadMembersUpdate = this.onThreadMembersUpdateController.stream;

    this.onThreadDeleteController = StreamController.broadcast();
    this.onThreadDelete = this.onThreadDeleteController.stream;

    this.onStageInstanceCreateController = StreamController.broadcast();
    this.onStageInstanceCreate = this.onStageInstanceCreateController.stream;

    this.onStageInstanceUpdateController = StreamController.broadcast();
    this.onStageInstanceUpdate = this.onStageInstanceUpdateController.stream;

    this.onStageInstanceDeleteController = StreamController.broadcast();
    this.onStageInstanceDelete = this.onStageInstanceDeleteController.stream;

    this.onGuildStickersUpdateController = StreamController.broadcast();
    this.onGuildStickersUpdate = this.onGuildStickersUpdateController.stream;
  }

  @override
  Future<void> dispose() async {
    await super.dispose();

    await this.onDisconnectController.close();
    await this.onGuildUpdateController.close();
    await this.onReadyController.close();
    await this.onMessageReceivedController.close();
    await this.onMessageUpdateController.close();
    await this.onMessageDeleteController.close();
    await this.onChannelCreateController.close();
    await this.onChannelUpdateController.close();
    await this.onChannelDeleteController.close();
    await this.onGuildBanAddController.close();
    await this.onGuildBanRemoveController.close();
    await this.onGuildCreateController.close();
    await this.onGuildUpdateController.close();
    await this.onGuildDeleteController.close();
    await this.onGuildMemberAddController.close();
    await this.onGuildMemberUpdateController.close();
    await this.onGuildMemberRemoveController.close();
    await this.onPresenceUpdateController.close();
    await this.onTypingController.close();
    await this.onRoleCreateController.close();
    await this.onRoleUpdateController.close();
    await this.onRoleDeleteController.close();

    await this.onChannelPinsUpdateController.close();
    await this.onGuildEmojisUpdateController.close();

    await this.onMessageDeleteBulkController.close();
    await this.onMessageReactionAddedController.close();
    await this.onMessageReactionRemoveController.close();
    await this.onMessageReactionsRemovedController.close();
    await this.onVoiceStateUpdateController.close();
    await this.onVoiceServerUpdateController.close();
    await this.onMessageReactionRemoveEmojiController.close();

    await this.onInviteCreatedController.close();
    await this.onInviteDeleteController.close();

    await this.onUserUpdateController.close();

    await this.onThreadCreatedController.close();
    await this.onThreadMembersUpdateController.close();
    await this.onThreadDeleteController.close();

    await this.onGuildStickersUpdateController.close();
  }
}
