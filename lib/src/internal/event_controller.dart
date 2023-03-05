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
import 'package:nyxx/src/events/thread_list_sync_event.dart';
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

  /// Emitted when a member joins a guild but is not yet screened by:
  /// https://support.discord.com/hc/en-us/articles/1500000466882
  Stream<IGuildMemberAddEvent> get onGuildMemberAddScreening;

  /// Emitted when a member joins a guild but passed member screening
  /// https://support.discord.com/hc/en-us/articles/1500000466882
  Stream<IGuildMemberUpdateEvent> get onGuildMemberAddPassedScreening;

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

  /// Emitted when an auto moderation rule was triggered and an action was executed (e.g. a message was blocked).
  Stream<IAutoModerationActionExecutionEvent> get onAutoModerationActionExecution;

  /// Sent when a guild audit log entry is created.
  Stream<IAuditLogEntryCreateEvent> get onAuditLogEntryCreate;

  /// Emitted when the thread member for the current user is updated in a guild.
  Stream<IThreadMemberUpdateEvent> get onThreadMemberUpdate;

  /// Emitted when a thread the user is in is updated.
  Stream<IThreadUpdateEvent> get onThreadUpdate;

  /// Sent when the thread list for a guild is synchronised.
  Stream<IThreadListSyncEvent> get onThreadListSync;
}

/// A controller for all events.
class WebsocketEventController extends RestEventController implements IWebsocketEventController {
  late final StreamController<IDisconnectEvent> onDisconnectController;
  late final StreamController<IReadyEvent> onReadyController;
  late final StreamController<IMessageReceivedEvent> onMessageReceivedController;
  late final StreamController<IChannelPinsUpdateEvent> onChannelPinsUpdateController;
  late final StreamController<IGuildEmojisUpdateEvent> onGuildEmojisUpdateController;
  late final StreamController<IMessageUpdateEvent> onMessageUpdateController;
  late final StreamController<IMessageDeleteEvent> onMessageDeleteController;
  late final StreamController<IChannelCreateEvent> onChannelCreateController;
  late final StreamController<IChannelUpdateEvent> onChannelUpdateController;
  late final StreamController<IChannelDeleteEvent> onChannelDeleteController;
  late final StreamController<IGuildBanAddEvent> onGuildBanAddController;
  late final StreamController<IGuildBanRemoveEvent> onGuildBanRemoveController;
  late final StreamController<IGuildCreateEvent> onGuildCreateController;
  late final StreamController<IGuildUpdateEvent> onGuildUpdateController;
  late final StreamController<IGuildDeleteEvent> onGuildDeleteController;
  late final StreamController<IGuildMemberAddEvent> onGuildMemberAddController;
  late final StreamController<IGuildMemberUpdateEvent> onGuildMemberUpdateController;
  late final StreamController<IGuildMemberRemoveEvent> onGuildMemberRemoveController;
  late final StreamController<IPresenceUpdateEvent> onPresenceUpdateController;
  late final StreamController<ITypingEvent> onTypingController;
  late final StreamController<IRoleCreateEvent> onRoleCreateController;
  late final StreamController<IRoleUpdateEvent> onRoleUpdateController;
  late final StreamController<IRoleDeleteEvent> onRoleDeleteController;
  late final StreamController<IMessageDeleteBulkEvent> onMessageDeleteBulkController;
  late final StreamController<IMessageReactionEvent> onMessageReactionAddedController;
  late final StreamController<IMessageReactionEvent> onMessageReactionRemoveController;
  late final StreamController<IMessageReactionsRemovedEvent> onMessageReactionsRemovedController;
  late final StreamController<IVoiceStateUpdateEvent> onVoiceStateUpdateController;
  late final StreamController<IVoiceServerUpdateEvent> onVoiceServerUpdateController;
  late final StreamController<IUserUpdateEvent> onUserUpdateController;
  late final StreamController<IInviteCreatedEvent> onInviteCreatedController;
  late final StreamController<IInviteDeletedEvent> onInviteDeleteController;
  late final StreamController<IMessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmojiController;
  late final StreamController<IThreadCreateEvent> onThreadCreatedController;
  late final StreamController<IThreadMembersUpdateEvent> onThreadMembersUpdateController;
  late final StreamController<IThreadDeletedEvent> onThreadDeleteController;
  late final StreamController<IStageInstanceEvent> onStageInstanceCreateController;
  late final StreamController<IStageInstanceEvent> onStageInstanceUpdateController;
  late final StreamController<IStageInstanceEvent> onStageInstanceDeleteController;
  late final StreamController<IGuildStickerUpdate> onGuildStickersUpdateController;
  late final StreamController<IGuildEventCreateEvent> onGuildEventCreateController;
  late final StreamController<IGuildEventDeleteEvent> onGuildEventDeleteController;
  late final StreamController<IGuildEventUpdateEvent> onGuildEventUpdateController;
  late final StreamController<IAutoModerationRuleCreateEvent> onAutoModerationRuleCreateController;
  late final StreamController<IAutoModerationRuleUpdateEvent> onAutoModerationRuleUpdateController;
  late final StreamController<IAutoModerationRuleDeleteEvent> onAutoModerationRuleDeleteController;
  late final StreamController<IWebhookUpdateEvent> onWebhookUpdateController;
  late final StreamController<IAutoModerationActionExecutionEvent> onAutoModerationActionExecutionController;
  late final StreamController<IAuditLogEntryCreateEvent> onAuditLogEntryCreateController;
  late final StreamController<IThreadMemberUpdateEvent> onThreadMemberUpdateController;
  late final StreamController<IThreadUpdateEvent> onThreadUpdateController;
  late final StreamController<IThreadListSyncEvent> onThreadListSyncController;

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

  @override
  late final Stream<IAutoModerationActionExecutionEvent> onAutoModerationActionExecution;

  @override
  late final Stream<IGuildMemberAddEvent> onGuildMemberAddScreening;

  @override
  late final Stream<IGuildMemberUpdateEvent> onGuildMemberAddPassedScreening;

  @override
  late final Stream<IAuditLogEntryCreateEvent> onAuditLogEntryCreate;

  @override
  late final Stream<IThreadMemberUpdateEvent> onThreadMemberUpdate;

  @override
  late final Stream<IThreadUpdateEvent> onThreadUpdate;

  @override
  late final Stream<IThreadListSyncEvent> onThreadListSync;

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

    onAutoModerationActionExecutionController = StreamController.broadcast();
    onAutoModerationActionExecution = onAutoModerationActionExecutionController.stream;

    onGuildMemberAddScreening = onGuildMemberAdd.where((event) => event.member.isPending);
    onGuildMemberAddPassedScreening = onGuildMemberUpdate.where((event) => !(event.member.getFromCache()?.isPending ?? true));

    onAuditLogEntryCreateController = StreamController.broadcast();
    onAuditLogEntryCreate = onAuditLogEntryCreateController.stream;

    onThreadMemberUpdateController = StreamController.broadcast();
    onThreadMemberUpdate = onThreadMemberUpdateController.stream;

    onThreadUpdateController = StreamController.broadcast();
    onThreadUpdate = onThreadUpdateController.stream;

    onThreadListSyncController = StreamController.broadcast();
    onThreadListSync = onThreadListSyncController.stream;
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

    await onAutoModerationActionExecutionController.close();

    await onAuditLogEntryCreateController.close();

    await onThreadMemberUpdateController.close();
    await onThreadUpdateController.close();
    await onThreadListSyncController.close();
  }
}
