import 'dart:async';

import 'package:nyxx/src/events/channel_events.dart';
import 'package:nyxx/src/events/disconnect_event.dart';
import 'package:nyxx/src/events/guild_events.dart';
import 'package:nyxx/src/events/http_events.dart';
import 'package:nyxx/src/events/invite_events.dart';
import 'package:nyxx/src/events/message_events.dart';
import 'package:nyxx/src/events/presence_update_event.dart';
import 'package:nyxx/src/events/ratelimit_event.dart';
import 'package:nyxx/src/events/ready_event.dart';
import 'package:nyxx/src/events/thread_create_event.dart';
import 'package:nyxx/src/events/thread_deleted_event.dart';
import 'package:nyxx/src/events/thread_members_update_event.dart';
import 'package:nyxx/src/events/typing_event.dart';
import 'package:nyxx/src/events/user_update_event.dart';
import 'package:nyxx/src/events/voice_server_update_event.dart';
import 'package:nyxx/src/events/voice_state_update_event.dart';
import 'package:nyxx/src/internal/interfaces/disposable.dart';
import 'package:nyxx/src/nyxx.dart';

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
    onHttpErrorController = StreamController.broadcast();
    onHttpError = onHttpErrorController.stream;

    onHttpResponseController = StreamController.broadcast();
    onHttpResponse = onHttpResponseController.stream;

    onRateLimitedController = StreamController.broadcast();
    onRateLimited = onRateLimitedController.stream;
  }

  @override
  Future<void> dispose() async {
    await onRateLimitedController.close();
    await onHttpResponseController.close();
    await onRateLimitedController.close();
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

  /// Emitted when stage channel instance is deleted
  Stream<IGuildEventCreateEvent> get onGuildEventCreate;

  /// Emitted when stage channel instance is deleted
  Stream<IGuildEventUpdateEvent> get onGuildEventUpdate;

  /// Emitted when stage channel instance is deleted
  Stream<IGuildEventDeleteEvent> get onGuildEventDelete;

  /// Emitted when an auto moderation rule is created
  Stream<IAutoModerationRuleCreateEvent> get onAutoModerationRuleCreate;

  /// Emitted when an auto moderation rule is updated
  Stream<IAutoModerationRuleUpdateEvent> get onAutoModerationRuleUpdate;

  /// Emitted when an auto moderation rule is deleted
  Stream<IAutoModerationRuleDeleteEvent> get onAutoModerationRuleDelete;

  /// Emitted when a webhook is created, updated or deleted.
  Stream<IWebhookUpdateEvent> get onWebhookUpdate;
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

  /// Guild scheduled event was created
  late final StreamController<IGuildEventCreateEvent> onGuildEventCreateController;

  /// Guild scheduled event was deleted
  late final StreamController<IGuildEventDeleteEvent> onGuildEventDeleteController;

  /// Guild scheduled event was updated
  late final StreamController<IGuildEventUpdateEvent> onGuildEventUpdateController;

  late final StreamController<IAutoModerationRuleCreateEvent> onAutoModerationRuleCreateController;

  late final StreamController<IAutoModerationRuleUpdateEvent> onAutoModerationRuleUpdateController;

  late final StreamController<IAutoModerationRuleDeleteEvent> onAutoModerationRuleDeleteController;

  late final StreamController<IWebhookUpdateEvent> onWebhookUpdateController;

  /// Emitted when a shard is disconnected from the websocket.
  @override
  late final Stream<IDisconnectEvent> onDisconnect;

  /// Emitted when the client is ready. Should be sent only once.
  @override
  late final Stream<IReadyEvent> onReady;

  /// Emitted when a message is received. It includes private messages.
  @override
  late final Stream<IMessageReceivedEvent> onMessageReceived;

  /// Emitted when private message is received.
  @override
  late final Stream<IMessageReceivedEvent> onDmReceived = onMessageReceived.where((event) => event.message.guild == null);

  /// Emitted when channel"s pins are updated.
  @override
  late final Stream<IChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild"s emojis are changed.
  @override
  late final Stream<IGuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited. Old message can be null if isn"t cached.
  @override
  late final Stream<IMessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is deleted.
  @override
  late final Stream<IMessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  @override
  late final Stream<IChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  @override
  late final Stream<IChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  @override
  late final Stream<IChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  @override
  late final Stream<IGuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  @override
  late final Stream<IGuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  @override
  late final Stream<IGuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated.
  @override
  late final Stream<IGuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  @override
  late final Stream<IGuildDeleteEvent> onGuildDelete;

  /// Emitted when a member joins a guild.
  @override
  late final Stream<IGuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  @override
  late final Stream<IGuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  @override
  late final Stream<IGuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member"s presence is changed.
  @override
  late final Stream<IPresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  @override
  late final Stream<ITypingEvent> onTyping;

  /// Emitted when a role is created.
  @override
  late final Stream<IRoleCreateEvent> onRoleCreate;

  /// Emitted when a role is updated.
  @override
  late final Stream<IRoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  @override
  late final Stream<IRoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  @override
  late final Stream<IMessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  @override
  late final Stream<IMessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  @override
  late final Stream<IMessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  @override
  late final Stream<IMessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channel.
  @override
  late final Stream<IVoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild"s voice server is updated.
  /// This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  @override
  late final Stream<IVoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when user was updated
  @override
  late final Stream<IUserUpdateEvent> onUserUpdate;

  /// Emitted when bot is mentioned
  @override
  late final Stream<IMessageReceivedEvent> onSelfMention =
      onMessageReceived.where((event) => event.message.mentions.map((e) => e.id).contains(_client.self.id));

  /// Emitted when invite is created
  @override
  late final Stream<IInviteCreatedEvent> onInviteCreated;

  /// Emitted when invite is deleted
  @override
  late final Stream<IInviteDeletedEvent> onInviteDeleted;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  @override
  late final Stream<IMessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmoji;

  /// Emitted when a thread is created
  @override
  late final Stream<IThreadCreateEvent> onThreadCreated;

  /// Fired when a thread has a member added/removed
  @override
  late final Stream<IThreadMembersUpdateEvent> onThreadMembersUpdate;

  /// Fired when a thread gets deleted
  @override
  late final Stream<IThreadDeletedEvent> onThreadDelete;

  /// Emitted when stage channel instance is created
  @override
  late final Stream<IStageInstanceEvent> onStageInstanceCreate;

  /// Emitted when stage channel instance is updated
  @override
  late final Stream<IStageInstanceEvent> onStageInstanceUpdate;

  /// Emitted when stage channel instance is deleted
  @override
  late final Stream<IStageInstanceEvent> onStageInstanceDelete;

  /// Emitted when stage channel instance is deleted
  @override
  late final Stream<IGuildStickerUpdate> onGuildStickersUpdate;

  /// Guild scheduled event was created
  @override
  late final Stream<IGuildEventCreateEvent> onGuildEventCreate;

  /// Guild scheduled event was deleted
  @override
  late final Stream<IGuildEventDeleteEvent> onGuildEventDelete;

  /// Guild scheduled event was updated
  @override
  late final Stream<IGuildEventUpdateEvent> onGuildEventUpdate;

  @override
  late final Stream<IAutoModerationRuleCreateEvent> onAutoModerationRuleCreate;

  @override
  late final Stream<IAutoModerationRuleUpdateEvent> onAutoModerationRuleUpdate;

  @override
  late final Stream<IAutoModerationRuleDeleteEvent> onAutoModerationRuleDelete;

  @override
  late final Stream<IWebhookUpdateEvent> onWebhookUpdate;

  final INyxxWebsocket _client;

  /// Makes a new `EventController`.
  WebsocketEventController(this._client) : super() {
    onDisconnectController = StreamController.broadcast();
    onDisconnect = onDisconnectController.stream;

    onReadyController = StreamController.broadcast();
    onReady = onReadyController.stream;

    onMessageReceivedController = StreamController.broadcast();
    onMessageReceived = onMessageReceivedController.stream;

    onMessageUpdateController = StreamController.broadcast();
    onMessageUpdate = onMessageUpdateController.stream;

    onMessageDeleteController = StreamController.broadcast();
    onMessageDelete = onMessageDeleteController.stream;

    onChannelCreateController = StreamController.broadcast();
    onChannelCreate = onChannelCreateController.stream;

    onChannelUpdateController = StreamController.broadcast();
    onChannelUpdate = onChannelUpdateController.stream;

    onChannelDeleteController = StreamController.broadcast();
    onChannelDelete = onChannelDeleteController.stream;

    onGuildBanAddController = StreamController.broadcast();
    onGuildBanAdd = onGuildBanAddController.stream;

    onGuildBanRemoveController = StreamController.broadcast();
    onGuildBanRemove = onGuildBanRemoveController.stream;

    onGuildCreateController = StreamController.broadcast();
    onGuildCreate = onGuildCreateController.stream;

    onGuildUpdateController = StreamController.broadcast();
    onGuildUpdate = onGuildUpdateController.stream;

    onGuildDeleteController = StreamController.broadcast();
    onGuildDelete = onGuildDeleteController.stream;

    onGuildMemberAddController = StreamController.broadcast();
    onGuildMemberAdd = onGuildMemberAddController.stream;

    onGuildMemberUpdateController = StreamController.broadcast();
    onGuildMemberUpdate = onGuildMemberUpdateController.stream;

    onGuildMemberRemoveController = StreamController.broadcast();
    onGuildMemberRemove = onGuildMemberRemoveController.stream;

    onPresenceUpdateController = StreamController.broadcast();
    onPresenceUpdate = onPresenceUpdateController.stream;

    onTypingController = StreamController.broadcast();
    onTyping = onTypingController.stream;

    onRoleCreateController = StreamController.broadcast();
    onRoleCreate = onRoleCreateController.stream;

    onRoleUpdateController = StreamController.broadcast();
    onRoleUpdate = onRoleUpdateController.stream;

    onRoleDeleteController = StreamController.broadcast();
    onRoleDelete = onRoleDeleteController.stream;

    onChannelPinsUpdateController = StreamController.broadcast();
    onChannelPinsUpdate = onChannelPinsUpdateController.stream;

    onGuildEmojisUpdateController = StreamController.broadcast();
    onGuildEmojisUpdate = onGuildEmojisUpdateController.stream;

    onMessageDeleteBulkController = StreamController.broadcast();
    onMessageDeleteBulk = onMessageDeleteBulkController.stream;

    onMessageReactionAddedController = StreamController.broadcast();
    onMessageReactionAdded = onMessageReactionAddedController.stream;

    onMessageReactionRemoveController = StreamController.broadcast();
    onMessageReactionRemove = onMessageReactionRemoveController.stream;

    onMessageReactionsRemovedController = StreamController.broadcast();
    onMessageReactionsRemoved = onMessageReactionsRemovedController.stream;

    onVoiceStateUpdateController = StreamController.broadcast();
    onVoiceStateUpdate = onVoiceStateUpdateController.stream;

    onVoiceServerUpdateController = StreamController.broadcast();
    onVoiceServerUpdate = onVoiceServerUpdateController.stream;

    onUserUpdateController = StreamController.broadcast();
    onUserUpdate = onUserUpdateController.stream;

    onInviteCreatedController = StreamController.broadcast();
    onInviteCreated = onInviteCreatedController.stream;

    onInviteDeleteController = StreamController.broadcast();
    onInviteDeleted = onInviteDeleteController.stream;

    onMessageReactionRemoveEmojiController = StreamController.broadcast();
    onMessageReactionRemoveEmoji = onMessageReactionRemoveEmojiController.stream;

    onThreadCreatedController = StreamController.broadcast();
    onThreadCreated = onThreadCreatedController.stream;

    onThreadMembersUpdateController = StreamController.broadcast();
    onThreadMembersUpdate = onThreadMembersUpdateController.stream;

    onThreadDeleteController = StreamController.broadcast();
    onThreadDelete = onThreadDeleteController.stream;

    onStageInstanceCreateController = StreamController.broadcast();
    onStageInstanceCreate = onStageInstanceCreateController.stream;

    onStageInstanceUpdateController = StreamController.broadcast();
    onStageInstanceUpdate = onStageInstanceUpdateController.stream;

    onStageInstanceDeleteController = StreamController.broadcast();
    onStageInstanceDelete = onStageInstanceDeleteController.stream;

    onGuildStickersUpdateController = StreamController.broadcast();
    onGuildStickersUpdate = onGuildStickersUpdateController.stream;

    onGuildEventCreateController = StreamController.broadcast();
    onGuildEventCreate = onGuildEventCreateController.stream;

    onGuildEventUpdateController = StreamController.broadcast();
    onGuildEventUpdate = onGuildEventUpdateController.stream;

    onGuildEventDeleteController = StreamController.broadcast();
    onGuildEventDelete = onGuildEventDeleteController.stream;

    onAutoModerationRuleCreateController = StreamController.broadcast();
    onAutoModerationRuleCreate = onAutoModerationRuleCreateController.stream;

    onAutoModerationRuleUpdateController = StreamController.broadcast();
    onAutoModerationRuleUpdate = onAutoModerationRuleUpdateController.stream;

    onAutoModerationRuleDeleteController = StreamController.broadcast();
    onAutoModerationRuleDelete = onAutoModerationRuleDeleteController.stream;

    onWebhookUpdateController = StreamController.broadcast();
    onWebhookUpdate = onWebhookUpdateController.stream;
  }

  @override
  Future<void> dispose() async {
    await super.dispose();

    await onDisconnectController.close();
    await onGuildUpdateController.close();
    await onReadyController.close();
    await onMessageReceivedController.close();
    await onMessageUpdateController.close();
    await onMessageDeleteController.close();
    await onChannelCreateController.close();
    await onChannelUpdateController.close();
    await onChannelDeleteController.close();
    await onGuildBanAddController.close();
    await onGuildBanRemoveController.close();
    await onGuildCreateController.close();
    await onGuildUpdateController.close();
    await onGuildDeleteController.close();
    await onGuildMemberAddController.close();
    await onGuildMemberUpdateController.close();
    await onGuildMemberRemoveController.close();
    await onPresenceUpdateController.close();
    await onTypingController.close();
    await onRoleCreateController.close();
    await onRoleUpdateController.close();
    await onRoleDeleteController.close();

    await onChannelPinsUpdateController.close();
    await onGuildEmojisUpdateController.close();

    await onMessageDeleteBulkController.close();
    await onMessageReactionAddedController.close();
    await onMessageReactionRemoveController.close();
    await onMessageReactionsRemovedController.close();
    await onVoiceStateUpdateController.close();
    await onVoiceServerUpdateController.close();
    await onMessageReactionRemoveEmojiController.close();

    await onInviteCreatedController.close();
    await onInviteDeleteController.close();

    await onUserUpdateController.close();

    await onThreadCreatedController.close();
    await onThreadMembersUpdateController.close();
    await onThreadDeleteController.close();

    await onGuildStickersUpdateController.close();

    await onGuildEventCreateController.close();
    await onGuildEventUpdateController.close();
    await onGuildEventDeleteController.close();

    await onAutoModerationRuleCreateController.close();
    await onAutoModerationRuleDeleteController.close();
    await onAutoModerationRuleUpdateController.close();

    await onWebhookUpdateController.close();
  }
}
