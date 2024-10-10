import 'dart:async';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/events/application_command.dart';
import 'package:nyxx/src/models/gateway/events/auto_moderation.dart';
import 'package:nyxx/src/models/gateway/events/channel.dart';
import 'package:nyxx/src/models/gateway/events/entitlement.dart';
import 'package:nyxx/src/models/gateway/events/guild.dart';
import 'package:nyxx/src/models/gateway/events/integration.dart';
import 'package:nyxx/src/models/gateway/events/interaction.dart';
import 'package:nyxx/src/models/gateway/events/invite.dart';
import 'package:nyxx/src/models/gateway/events/message.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';
import 'package:nyxx/src/models/gateway/events/ready.dart';
import 'package:nyxx/src/models/gateway/events/stage_instance.dart';
import 'package:nyxx/src/models/gateway/events/voice.dart';
import 'package:nyxx/src/models/gateway/events/webhook.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/utils/iterable_extension.dart';

/// An internal mixin to add event streams to a NyxxGateway client.
mixin EventMixin implements Nyxx {
  /// A [Stream] of gateway dispatch events received by this client.
  Stream<DispatchEvent> get onEvent => (this as NyxxGateway).gateway.events;

  /// A [Stream] of [DispatchEvent]s which are unknown to the current version of nyxx.
  Stream<UnknownDispatchEvent> get onUnknownEvent => onEvent.whereType<UnknownDispatchEvent>();

  /// A helper function to listen to events of a specific type.
  ///
  /// Specifying the type parameter is important, as the callback will otherwise be invoked for every event received by the client.
  ///
  /// The following two code examples are equivalent:
  /// ```dart
  /// client.on<MessageCreateEvent>((event) => print(event.message.content));
  /// ```
  ///
  /// ```dart
  /// client.onMessageCreate.listen((event) => print(event.message.content));
  /// ```
  StreamSubscription<T> on<T extends DispatchEvent>(void Function(T event) onData) => onEvent.whereType<T>().listen(onData);

  /// A [Stream] of [ReadyEvent]s received by this client.
  Stream<ReadyEvent> get onReady => onEvent.whereType<ReadyEvent>();

  /// A [Stream] of [ResumedEvent]s received by this client.
  Stream<ResumedEvent> get onResumed => onEvent.whereType<ResumedEvent>();

  /// A [Stream] of [ApplicationCommandPermissionsUpdateEvent]s received by this client.
  Stream<ApplicationCommandPermissionsUpdateEvent> get onApplicationCommandPermissionsUpdate => onEvent.whereType<ApplicationCommandPermissionsUpdateEvent>();

  /// A [Stream] of [AutoModerationRuleCreateEvent]s received by this client.
  Stream<AutoModerationRuleCreateEvent> get onAutoModerationRuleCreate => onEvent.whereType<AutoModerationRuleCreateEvent>();

  /// A [Stream] of [AutoModerationRuleUpdateEvent]s received by this client.
  Stream<AutoModerationRuleUpdateEvent> get onAutoModerationRuleUpdate => onEvent.whereType<AutoModerationRuleUpdateEvent>();

  /// A [Stream] of [AutoModerationRuleDeleteEvent]s received by this client.
  Stream<AutoModerationRuleDeleteEvent> get onAutoModerationRuleDelete => onEvent.whereType<AutoModerationRuleDeleteEvent>();

  /// A [Stream] of [AutoModerationActionExecutionEvent]s received by this client.
  Stream<AutoModerationActionExecutionEvent> get onAutoModerationActionExecution => onEvent.whereType<AutoModerationActionExecutionEvent>();

  /// A [Stream] of [ChannelCreateEvent]s received by this client.
  Stream<ChannelCreateEvent> get onChannelCreate => onEvent.whereType<ChannelCreateEvent>();

  /// A [Stream] of [ChannelUpdateEvent]s received by this client.
  Stream<ChannelUpdateEvent> get onChannelUpdate => onEvent.whereType<ChannelUpdateEvent>();

  /// A [Stream] of [ChannelDeleteEvent]s received by this client.
  Stream<ChannelDeleteEvent> get onChannelDelete => onEvent.whereType<ChannelDeleteEvent>();

  /// A [Stream] of [ThreadCreateEvent]s received by this client.
  Stream<ThreadCreateEvent> get onThreadCreate => onEvent.whereType<ThreadCreateEvent>();

  /// A [Stream] of [ThreadUpdateEvent]s received by this client.
  Stream<ThreadUpdateEvent> get onThreadUpdate => onEvent.whereType<ThreadUpdateEvent>();

  /// A [Stream] of [ThreadDeleteEvent]s received by this client.
  Stream<ThreadDeleteEvent> get onThreadDelete => onEvent.whereType<ThreadDeleteEvent>();

  /// A [Stream] of [ThreadListSyncEvent]s received by this client.
  Stream<ThreadListSyncEvent> get onThreadListSync => onEvent.whereType<ThreadListSyncEvent>();

  /// A [Stream] of [ThreadMemberUpdateEvent]s received by this client.
  Stream<ThreadMemberUpdateEvent> get onThreadMemberUpdate => onEvent.whereType<ThreadMemberUpdateEvent>();

  /// A [Stream] of [ThreadMembersUpdateEvent]s received by this client.
  Stream<ThreadMembersUpdateEvent> get onThreadMembersUpdate => onEvent.whereType<ThreadMembersUpdateEvent>();

  /// A [Stream] of [ChannelPinsUpdateEvent]s received by this client.
  Stream<ChannelPinsUpdateEvent> get onChannelPinsUpdate => onEvent.whereType<ChannelPinsUpdateEvent>();

  /// A [Stream] of [UnavailableGuildCreateEvent]s received by this client.
  ///
  /// This stream also emits [GuildCreateEvent]s, as they are a subtype of [UnavailableGuildCreateEvent].
  Stream<UnavailableGuildCreateEvent> get onGuildCreate => onEvent.whereType<UnavailableGuildCreateEvent>();

  /// A [Stream] of [GuildUpdateEvent]s received by this client.
  Stream<GuildUpdateEvent> get onGuildUpdate => onEvent.whereType<GuildUpdateEvent>();

  /// A [Stream] of [GuildDeleteEvent]s received by this client.
  Stream<GuildDeleteEvent> get onGuildDelete => onEvent.whereType<GuildDeleteEvent>();

  /// A [Stream] of [GuildAuditLogCreateEvent]s received by this client.
  Stream<GuildAuditLogCreateEvent> get onGuildAuditLogCreate => onEvent.whereType<GuildAuditLogCreateEvent>();

  /// A [Stream] of [GuildBanAddEvent]s received by this client.
  Stream<GuildBanAddEvent> get onGuildBanAdd => onEvent.whereType<GuildBanAddEvent>();

  /// A [Stream] of [GuildBanRemoveEvent]s received by this client.
  Stream<GuildBanRemoveEvent> get onGuildBanRemove => onEvent.whereType<GuildBanRemoveEvent>();

  /// A [Stream] of [GuildEmojisUpdateEvent]s received by this client.
  Stream<GuildEmojisUpdateEvent> get onGuildEmojisUpdate => onEvent.whereType<GuildEmojisUpdateEvent>();

  /// A [Stream] of [GuildStickersUpdateEvent]s received by this client.
  Stream<GuildStickersUpdateEvent> get onGuildStickersUpdate => onEvent.whereType<GuildStickersUpdateEvent>();

  /// A [Stream] of [GuildIntegrationsUpdateEvent]s received by this client.
  Stream<GuildIntegrationsUpdateEvent> get onGuildIntegrationsUpdate => onEvent.whereType<GuildIntegrationsUpdateEvent>();

  /// A [Stream] of [GuildMemberAddEvent]s received by this client.
  Stream<GuildMemberAddEvent> get onGuildMemberAdd => onEvent.whereType<GuildMemberAddEvent>();

  /// A [Stream] of [GuildMemberRemoveEvent]s received by this client.
  Stream<GuildMemberRemoveEvent> get onGuildMemberRemove => onEvent.whereType<GuildMemberRemoveEvent>();

  /// A [Stream] of [GuildMemberUpdateEvent]s received by this client.
  Stream<GuildMemberUpdateEvent> get onGuildMemberUpdate => onEvent.whereType<GuildMemberUpdateEvent>();

  /// A [Stream] of [GuildMembersChunkEvent]s received by this client.
  Stream<GuildMembersChunkEvent> get onGuildMembersChunk => onEvent.whereType<GuildMembersChunkEvent>();

  /// A [Stream] of [GuildRoleCreateEvent]s received by this client.
  Stream<GuildRoleCreateEvent> get onGuildRoleCreate => onEvent.whereType<GuildRoleCreateEvent>();

  /// A [Stream] of [GuildRoleUpdateEvent]s received by this client.
  Stream<GuildRoleUpdateEvent> get onGuildRoleUpdate => onEvent.whereType<GuildRoleUpdateEvent>();

  /// A [Stream] of [GuildRoleDeleteEvent]s received by this client.
  Stream<GuildRoleDeleteEvent> get onGuildRoleDelete => onEvent.whereType<GuildRoleDeleteEvent>();

  /// A [Stream] of [GuildScheduledEventCreateEvent]s received by this client.
  Stream<GuildScheduledEventCreateEvent> get onGuildScheduledEventCreate => onEvent.whereType<GuildScheduledEventCreateEvent>();

  /// A [Stream] of [GuildScheduledEventUpdateEvent]s received by this client.
  Stream<GuildScheduledEventUpdateEvent> get onGuildScheduledEventUpdate => onEvent.whereType<GuildScheduledEventUpdateEvent>();

  /// A [Stream] of [GuildScheduledEventDeleteEvent]s received by this client.
  Stream<GuildScheduledEventDeleteEvent> get onGuildScheduledEventDelete => onEvent.whereType<GuildScheduledEventDeleteEvent>();

  /// A [Stream] of [GuildScheduledEventUserAddEvent]s received by this client.
  Stream<GuildScheduledEventUserAddEvent> get onGuildScheduledEventUserAdd => onEvent.whereType<GuildScheduledEventUserAddEvent>();

  /// A [Stream] of [GuildScheduledEventUserRemoveEvent]s received by this client.
  Stream<GuildScheduledEventUserRemoveEvent> get onGuildScheduledEventUserRemove => onEvent.whereType<GuildScheduledEventUserRemoveEvent>();

  /// A [Stream] of [IntegrationCreateEvent]s received by this client.
  Stream<IntegrationCreateEvent> get onIntegrationCreate => onEvent.whereType<IntegrationCreateEvent>();

  /// A [Stream] of [IntegrationUpdateEvent]s received by this client.
  Stream<IntegrationUpdateEvent> get onIntegrationUpdate => onEvent.whereType<IntegrationUpdateEvent>();

  /// A [Stream] of [IntegrationDeleteEvent]s received by this client.
  Stream<IntegrationDeleteEvent> get onIntegrationDelete => onEvent.whereType<IntegrationDeleteEvent>();

  /// A [Stream] of [InviteCreateEvent]s received by this client.
  Stream<InviteCreateEvent> get onInviteCreate => onEvent.whereType<InviteCreateEvent>();

  /// A [Stream] of [InviteDeleteEvent]s received by this client.
  Stream<InviteDeleteEvent> get onInviteDelete => onEvent.whereType<InviteDeleteEvent>();

  /// A [Stream] of [MessageCreateEvent]s received by this client.
  Stream<MessageCreateEvent> get onMessageCreate => onEvent.whereType<MessageCreateEvent>();

  /// A [Stream] of [MessageUpdateEvent]s received by this client.
  Stream<MessageUpdateEvent> get onMessageUpdate => onEvent.whereType<MessageUpdateEvent>();

  /// A [Stream] of [MessageDeleteEvent]s received by this client.
  Stream<MessageDeleteEvent> get onMessageDelete => onEvent.whereType<MessageDeleteEvent>();

  /// A [Stream] of [MessageBulkDeleteEvent]s received by this client.
  Stream<MessageBulkDeleteEvent> get onMessageBulkDelete => onEvent.whereType<MessageBulkDeleteEvent>();

  /// A [Stream] of [MessageReactionAddEvent]s received by this client.
  Stream<MessageReactionAddEvent> get onMessageReactionAdd => onEvent.whereType<MessageReactionAddEvent>();

  /// A [Stream] of [MessageReactionRemoveEvent]s received by this client.
  Stream<MessageReactionRemoveEvent> get onMessageReactionRemove => onEvent.whereType<MessageReactionRemoveEvent>();

  /// A [Stream] of [MessageReactionRemoveAllEvent]s received by this client.
  Stream<MessageReactionRemoveAllEvent> get onMessageReactionRemoveAll => onEvent.whereType<MessageReactionRemoveAllEvent>();

  /// A [Stream] of [MessageReactionRemoveEmojiEvent]s received by this client.
  Stream<MessageReactionRemoveEmojiEvent> get onMessageReactionRemoveEmoji => onEvent.whereType<MessageReactionRemoveEmojiEvent>();

  /// A [Stream] of [PresenceUpdateEvent]s received by this client.
  Stream<PresenceUpdateEvent> get onPresenceUpdate => onEvent.whereType<PresenceUpdateEvent>();

  /// A [Stream] of [TypingStartEvent]s received by this client.
  Stream<TypingStartEvent> get onTypingStart => onEvent.whereType<TypingStartEvent>();

  /// A [Stream] of [UserUpdateEvent]s received by this client.
  Stream<UserUpdateEvent> get onUserUpdate => onEvent.whereType<UserUpdateEvent>();

  /// A [Stream] of [VoiceStateUpdateEvent]s received by this client.
  Stream<VoiceStateUpdateEvent> get onVoiceStateUpdate => onEvent.whereType<VoiceStateUpdateEvent>();

  /// A [Stream] of [VoiceServerUpdateEvent]s received by this client.
  Stream<VoiceServerUpdateEvent> get onVoiceServerUpdate => onEvent.whereType<VoiceServerUpdateEvent>();

  /// A [Stream] of [WebhooksUpdateEvent]s received by this client.
  Stream<WebhooksUpdateEvent> get onWebhooksUpdate => onEvent.whereType<WebhooksUpdateEvent>();

  /// A [Stream] of [InteractionCreateEvent]s received by this client.
  Stream<InteractionCreateEvent> get onInteractionCreate => onEvent.whereType<InteractionCreateEvent>();

  /// A [Stream] of [StageInstanceCreateEvent]s received by this client.
  Stream<StageInstanceCreateEvent> get onStageInstanceCreate => onEvent.whereType<StageInstanceCreateEvent>();

  /// A [Stream] of [StageInstanceUpdateEvent]s received by this client.
  Stream<StageInstanceUpdateEvent> get onStageInstanceUpdate => onEvent.whereType<StageInstanceUpdateEvent>();

  /// A [Stream] of [StageInstanceDeleteEvent]s received by this client.
  Stream<StageInstanceDeleteEvent> get onStageInstanceDelete => onEvent.whereType<StageInstanceDeleteEvent>();

  /// A [Stream] of [EntitlementCreateEvent]s received by this client.
  Stream<EntitlementCreateEvent> get onEntitlementCreate => onEvent.whereType<EntitlementCreateEvent>();

  /// A [Stream] of [EntitlementUpdateEvent]s received by this client.
  Stream<EntitlementUpdateEvent> get onEntitlementUpdate => onEvent.whereType<EntitlementUpdateEvent>();

  /// A [Stream] of [EntitlementDeleteEvent]s received by this client.
  Stream<EntitlementDeleteEvent> get onEntitlementDelete => onEvent.whereType<EntitlementDeleteEvent>();

  // Specializations of [onInteractionCreate] for convenience.

  /// A [Stream] of [PingInteraction]s received by this client.
  Stream<InteractionCreateEvent<PingInteraction>> get onPingInteraction => onInteractionCreate.whereType<InteractionCreateEvent<PingInteraction>>();

  /// A [Stream] of [ApplicationCommandInteraction]s received by this client.
  Stream<InteractionCreateEvent<ApplicationCommandInteraction>> get onApplicationCommandInteraction =>
      onInteractionCreate.whereType<InteractionCreateEvent<ApplicationCommandInteraction>>();

  /// A [Stream] of [MessageComponentInteraction]s received by this client.
  Stream<InteractionCreateEvent<MessageComponentInteraction>> get onMessageComponentInteraction =>
      onInteractionCreate.whereType<InteractionCreateEvent<MessageComponentInteraction>>();

  /// A [Stream] of [ModalSubmitInteraction]s received by this client.
  Stream<InteractionCreateEvent<ModalSubmitInteraction>> get onModalSubmitInteraction =>
      onInteractionCreate.whereType<InteractionCreateEvent<ModalSubmitInteraction>>();

  /// A [Stream] of [ApplicationCommandAutocompleteInteraction]s received by this client.
  Stream<InteractionCreateEvent<ApplicationCommandAutocompleteInteraction>> get onApplicationCommandAutocompleteInteraction =>
      onInteractionCreate.whereType<InteractionCreateEvent<ApplicationCommandAutocompleteInteraction>>();

  /// A [Stream] of [MessagePollVoteAddEvent]s received by this client.
  Stream<MessagePollVoteAddEvent> get onMessagePollVoteAdd => onEvent.whereType<MessagePollVoteAddEvent>();

  /// A [Stream] of [MessagePollVoteRemoveEvent]s received by this client.
  Stream<MessagePollVoteRemoveEvent> get onMessagePollVoteRemove => onEvent.whereType<MessagePollVoteRemoveEvent>();
}
