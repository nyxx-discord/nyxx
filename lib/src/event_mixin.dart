import 'dart:async';

import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/events/application_command.dart';
import 'package:nyxx/src/models/gateway/events/auto_moderation.dart';
import 'package:nyxx/src/models/gateway/events/channel.dart';
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
import 'package:nyxx/src/utils/iterable_extension.dart';

mixin EventMixin implements Nyxx {
  Stream<DispatchEvent> get onEvent => (this as NyxxGateway).gateway.events;

  Stream<UnknownDispatchEvent> get onUnknownEvent => onEvent.whereType<UnknownDispatchEvent>();

  StreamSubscription<T> on<T extends DispatchEvent>(void Function(T event) onData) => onEvent.whereType<T>().listen(onData);

  Stream<ReadyEvent> get onReady => onEvent.whereType<ReadyEvent>();
  Stream<ResumedEvent> get onResumed => onEvent.whereType<ResumedEvent>();
  Stream<ApplicationCommandPermissionsUpdateEvent> get onApplicationCommandPermissionsUpdate => onEvent.whereType<ApplicationCommandPermissionsUpdateEvent>();
  Stream<AutoModerationRuleCreateEvent> get onAutoModerationRuleCreate => onEvent.whereType<AutoModerationRuleCreateEvent>();
  Stream<AutoModerationRuleUpdateEvent> get onAutoModerationRuleUpdate => onEvent.whereType<AutoModerationRuleUpdateEvent>();
  Stream<AutoModerationRuleDeleteEvent> get onAutoModerationRuleDelete => onEvent.whereType<AutoModerationRuleDeleteEvent>();
  Stream<AutoModerationActionExecutionEvent> get onAutoModerationActionExecution => onEvent.whereType<AutoModerationActionExecutionEvent>();
  Stream<ChannelCreateEvent> get onChannelCreate => onEvent.whereType<ChannelCreateEvent>();
  Stream<ChannelUpdateEvent> get onChannelUpdate => onEvent.whereType<ChannelUpdateEvent>();
  Stream<ChannelDeleteEvent> get onChannelDelete => onEvent.whereType<ChannelDeleteEvent>();
  Stream<ThreadCreateEvent> get onThreadCreate => onEvent.whereType<ThreadCreateEvent>();
  Stream<ThreadUpdateEvent> get onThreadUpdate => onEvent.whereType<ThreadUpdateEvent>();
  Stream<ThreadDeleteEvent> get onThreadDelete => onEvent.whereType<ThreadDeleteEvent>();
  Stream<ThreadListSyncEvent> get onThreadListSync => onEvent.whereType<ThreadListSyncEvent>();
  Stream<ThreadMemberUpdateEvent> get onThreadMemberUpdate => onEvent.whereType<ThreadMemberUpdateEvent>();
  Stream<ThreadMembersUpdateEvent> get onThreadMembersUpdate => onEvent.whereType<ThreadMembersUpdateEvent>();
  Stream<ChannelPinsUpdateEvent> get onChannelPinsUpdate => onEvent.whereType<ChannelPinsUpdateEvent>();
  Stream<GuildCreateEvent> get onGuildCreate => onEvent.whereType<GuildCreateEvent>();
  Stream<GuildUpdateEvent> get onGuildUpdate => onEvent.whereType<GuildUpdateEvent>();
  Stream<GuildDeleteEvent> get onGuildDelete => onEvent.whereType<GuildDeleteEvent>();
  Stream<GuildBanAddEvent> get onGuildBanAdd => onEvent.whereType<GuildBanAddEvent>();
  Stream<GuildBanRemoveEvent> get onGuildBanRemove => onEvent.whereType<GuildBanRemoveEvent>();
  Stream<GuildEmojisUpdateEvent> get onGuildEmojisUpdate => onEvent.whereType<GuildEmojisUpdateEvent>();
  Stream<GuildStickersUpdateEvent> get onGuildStickersUpdate => onEvent.whereType<GuildStickersUpdateEvent>();
  Stream<GuildIntegrationsUpdateEvent> get onGuildIntegrationsUpdate => onEvent.whereType<GuildIntegrationsUpdateEvent>();
  Stream<GuildMemberAddEvent> get onGuildMemberAdd => onEvent.whereType<GuildMemberAddEvent>();
  Stream<GuildMemberRemoveEvent> get onGuildMemberRemove => onEvent.whereType<GuildMemberRemoveEvent>();
  Stream<GuildMemberUpdateEvent> get onGuildMemberUpdate => onEvent.whereType<GuildMemberUpdateEvent>();
  Stream<GuildMembersChunkEvent> get onGuildMembersChunk => onEvent.whereType<GuildMembersChunkEvent>();
  Stream<GuildRoleCreateEvent> get onGuildRoleCreate => onEvent.whereType<GuildRoleCreateEvent>();
  Stream<GuildRoleUpdateEvent> get onGuildRoleUpdate => onEvent.whereType<GuildRoleUpdateEvent>();
  Stream<GuildRoleDeleteEvent> get onGuildRoleDelete => onEvent.whereType<GuildRoleDeleteEvent>();
  Stream<GuildScheduledEventCreateEvent> get onGuildScheduledEventCreate => onEvent.whereType<GuildScheduledEventCreateEvent>();
  Stream<GuildScheduledEventUpdateEvent> get onGuildScheduledEventUpdate => onEvent.whereType<GuildScheduledEventUpdateEvent>();
  Stream<GuildScheduledEventDeleteEvent> get onGuildScheduledEventDelete => onEvent.whereType<GuildScheduledEventDeleteEvent>();
  Stream<GuildScheduledEventUserAddEvent> get onGuildScheduledEventUserAdd => onEvent.whereType<GuildScheduledEventUserAddEvent>();
  Stream<GuildScheduledEventUserRemoveEvent> get onGuildScheduledEventUserRemove => onEvent.whereType<GuildScheduledEventUserRemoveEvent>();
  Stream<IntegrationCreateEvent> get onIntegrationCreate => onEvent.whereType<IntegrationCreateEvent>();
  Stream<IntegrationUpdateEvent> get onIntegrationUpdate => onEvent.whereType<IntegrationUpdateEvent>();
  Stream<IntegrationDeleteEvent> get onIntegrationDelete => onEvent.whereType<IntegrationDeleteEvent>();
  Stream<InviteCreateEvent> get onInviteCreate => onEvent.whereType<InviteCreateEvent>();
  Stream<InviteDeleteEvent> get onInviteDelete => onEvent.whereType<InviteDeleteEvent>();
  Stream<MessageCreateEvent> get onMessageCreate => onEvent.whereType<MessageCreateEvent>();
  Stream<MessageUpdateEvent> get onMessageUpdate => onEvent.whereType<MessageUpdateEvent>();
  Stream<MessageDeleteEvent> get onMessageDelete => onEvent.whereType<MessageDeleteEvent>();
  Stream<MessageBulkDeleteEvent> get onMessageBulkDelete => onEvent.whereType<MessageBulkDeleteEvent>();
  Stream<MessageReactionAddEvent> get onMessageReactionAdd => onEvent.whereType<MessageReactionAddEvent>();
  Stream<MessageReactionRemoveEvent> get onMessageReactionRemove => onEvent.whereType<MessageReactionRemoveEvent>();
  Stream<MessageReactionRemoveAllEvent> get onMessageReactionRemoveAll => onEvent.whereType<MessageReactionRemoveAllEvent>();
  Stream<MessageReactionRemoveEmojiEvent> get onMessageReactionRemoveEmoji => onEvent.whereType<MessageReactionRemoveEmojiEvent>();
  Stream<PresenceUpdateEvent> get onPresenceUpdate => onEvent.whereType<PresenceUpdateEvent>();
  Stream<TypingStartEvent> get onTypingStart => onEvent.whereType<TypingStartEvent>();
  Stream<UserUpdateEvent> get onUserUpdate => onEvent.whereType<UserUpdateEvent>();
  Stream<VoiceStateUpdateEvent> get onVoiceStateUpdate => onEvent.whereType<VoiceStateUpdateEvent>();
  Stream<VoiceServerUpdateEvent> get onVoiceServerUpdate => onEvent.whereType<VoiceServerUpdateEvent>();
  Stream<WebhooksUpdateEvent> get onWebhooksUpdate => onEvent.whereType<WebhooksUpdateEvent>();
  Stream<InteractionCreateEvent> get onInteractionCreate => onEvent.whereType<InteractionCreateEvent>();
  Stream<StageInstanceCreateEvent> get onStageInstanceCreate => onEvent.whereType<StageInstanceCreateEvent>();
  Stream<StageInstanceUpdateEvent> get onStageInstanceUpdate => onEvent.whereType<StageInstanceUpdateEvent>();
  Stream<StageInstanceDeleteEvent> get onStageInstanceDelete => onEvent.whereType<StageInstanceDeleteEvent>();
}
