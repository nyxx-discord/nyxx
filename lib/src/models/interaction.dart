import 'package:nyxx/src/builders/application_command.dart';
import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/interaction_response.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/managers/interaction_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/message/attachment.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A context indicating whether command can be used in DMs, groups, or guilds.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-context-types
final class InteractionContextType extends EnumLike<int, InteractionContextType> {
  /// Interaction can be used within servers.
  static const InteractionContextType guild = InteractionContextType(0);

  /// Interaction can be used within DMs with the app's bot user.
  static const InteractionContextType botDm = InteractionContextType(1);

  /// Interaction can be used within Group DMs and DMs other than the app's bot user.
  static const InteractionContextType privateChannel = InteractionContextType(2);

  /// @nodoc
  const InteractionContextType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  InteractionContextType.parse(int value) : this(value);
}

/// {@template interaction}
/// An interaction sent by Discord when a user interacts with an [ApplicationCommand], a [MessageComponent]
/// or a [ModalBuilder].
/// {@endtemplate}
abstract class Interaction<T> with ToStringHelper {
  /// The manager for this interaction.
  final InteractionManager manager;

  /// The ID of this interaction.
  final Snowflake id;

  /// The ID of the application this interaction is for.
  final Snowflake applicationId;

  /// The type of this interaction.
  final InteractionType type;

  /// The data payload associated with this interaction.
  final T data;

  /// The ID of the guild this interaction was triggered in.
  final Snowflake? guildId;

  /// The channel this interaction was triggered in.
  final PartialChannel? channel;

  /// The ID of the channel this interaction was triggered in.
  final Snowflake? channelId;

  /// The member that triggered this interaction.
  final Member? member;

  /// The user that triggered this interaction.
  final User? user;

  /// The token to use when responding to this interaction.
  final String token;

  /// The interaction version.
  final int version;

  /// The message this interaction was triggered on.
  final Message? message;

  /// The permissions of the application that triggered this interaction.
  final Permissions appPermissions;

  /// The preferred locale of the user that triggered this interaction.
  final Locale? locale;

  /// The preferred locale of the guild in which this interaction was triggered.
  final Locale? guildLocale;

  /// The entitlements for the user and guild of this interaction.
  final List<Entitlement> entitlements;

  /// Mapping of installation contexts that the interaction was authorized for to related user or guild IDs.
  final Map<ApplicationIntegrationType, Snowflake>? authorizingIntegrationOwners;

  /// Context where the interaction was triggered from.
  final InteractionContextType? context;

  /// Represents the maximun allowed size per-attachment for the given interaction
  final int attachmentSizeLimit;

  /// {@macro interaction}
  /// @nodoc
  Interaction({
    required this.manager,
    required this.id,
    required this.applicationId,
    required this.type,
    required this.data,
    required this.guildId,
    required this.channel,
    required this.channelId,
    required this.member,
    required this.user,
    required this.token,
    required this.version,
    required this.message,
    required this.appPermissions,
    required this.locale,
    required this.guildLocale,
    required this.entitlements,
    required this.authorizingIntegrationOwners,
    required this.context,
    required this.attachmentSizeLimit,
  });

  /// The guild in which this interaction was triggered.
  PartialGuild? get guild => guildId == null ? null : manager.client.guilds[guildId!];
}

mixin MessageResponse<T> on Interaction<T> {
  /// Whether this interaction has been acknowledged or responded to
  bool _didAcknowledge = false;
  bool _didRespond = false;
  bool? _wasEphemeral;

  /// Acknowledge this interaction.
  Future<InteractionCallbackResponse?> acknowledge({bool? isEphemeral, bool? withResponse}) async {
    if (_didAcknowledge) {
      throw AlreadyAcknowledgedError(this);
    }

    _didAcknowledge = true;
    _wasEphemeral = isEphemeral;

    return manager.createResponse(id, token, InteractionResponseBuilder.deferredChannelMessage(isEphemeral: isEphemeral), withResponse: withResponse);
  }

  /// Send a response to this interaction.
  Future<InteractionCallbackResponse?> respond(
    MessageBuilder builder, {
    @Deprecated('Use MessageBuilder.flags instead') bool? isEphemeral,
    bool? withResponse,
  }) async {
    if (_didRespond) {
      throw AlreadyRespondedError(this);
    }

    if (!_didAcknowledge) {
      _didAcknowledge = true;
      _didRespond = true;
      _wasEphemeral = isEphemeral;

      // ignore: deprecated_member_use_from_same_package
      return manager.createResponse(id, token, InteractionResponseBuilder.channelMessage(builder, isEphemeral: isEphemeral), withResponse: withResponse);
    } else {
      assert(isEphemeral == _wasEphemeral || isEphemeral == null, 'Cannot change the value of isEphemeral between acknowledge and respond');
      _didRespond = true;

      await manager.createFollowup(token, builder);
    }

    return null;
  }

  /// Fetch the original response to this interaction.
  Future<Message> fetchOriginalResponse() => manager.fetchOriginalResponse(token);

  /// Update the original response to this interaction.
  Future<Message> updateOriginalResponse(MessageUpdateBuilder builder) => manager.updateOriginalResponse(token, builder);

  /// Delete the original response to this interaction.
  Future<void> deleteOriginalResponse() => manager.deleteOriginalResponse(token);

  /// Create a followup to this interaction.
  Future<Message> createFollowup(MessageBuilder builder, {bool? isEphemeral}) => manager.createFollowup(token, builder, isEphemeral: isEphemeral);

  /// Fetch a followup to this interaction.
  Future<Message> fetchFollowup(Snowflake id) => manager.fetchFollowup(token, id);

  /// Update a followup to this interaction.
  Future<Message> updateFollowup(Snowflake id, MessageUpdateBuilder builder) => manager.updateFollowup(token, id, builder);

  /// Delete a followup to this interaction.
  Future<void> deleteFollowup(Snowflake id) => manager.deleteFollowup(token, id);
}

mixin ModalResponse<T> on Interaction<T> {
  abstract bool _didRespond;
  abstract bool _didAcknowledge;

  /// Send a modal response to this interaction.
  Future<void> respondModal(ModalBuilder builder) async {
    assert(!_didAcknowledge, 'Cannot open a modal after a response or acknowledge has been sent');

    _didAcknowledge = true;
    _didRespond = true;

    await manager.createResponse(id, token, InteractionResponseBuilder.modal(builder));
  }
}

/// {@template ping_interaction}
/// A ping interaction.
/// {@endtemplate}
class PingInteraction extends Interaction<void> {
  /// {@macro ping_interaction}
  /// @nodoc
  PingInteraction({
    required super.manager,
    required super.id,
    required super.applicationId,
    required super.type,
    required super.guildId,
    required super.channel,
    required super.channelId,
    required super.member,
    required super.user,
    required super.token,
    required super.version,
    required super.message,
    required super.appPermissions,
    required super.locale,
    required super.guildLocale,
    required super.entitlements,
    required super.authorizingIntegrationOwners,
    required super.context,
    required super.attachmentSizeLimit,
  }) : super(data: null);

  /// Send a pong response to this interaction.
  Future<void> respond() => manager.createResponse(id, token, InteractionResponseBuilder.pong());
}

/// {@template application_command_interaction}
/// An application command interaction.
/// {@endtemplate}
class ApplicationCommandInteraction extends Interaction<ApplicationCommandInteractionData>
    with MessageResponse<ApplicationCommandInteractionData>, ModalResponse<ApplicationCommandInteractionData> {
  /// {@macro application_command_interaction}
  /// @nodoc
  ApplicationCommandInteraction({
    required super.manager,
    required super.id,
    required super.applicationId,
    required super.type,
    required super.data,
    required super.guildId,
    required super.channel,
    required super.channelId,
    required super.member,
    required super.user,
    required super.token,
    required super.version,
    required super.message,
    required super.appPermissions,
    required super.locale,
    required super.guildLocale,
    required super.entitlements,
    required super.authorizingIntegrationOwners,
    required super.context,
    required super.attachmentSizeLimit,
  });
}

/// {@template message_component_interaction}
/// A message component interaction.
/// {@endtemplate}
class MessageComponentInteraction extends Interaction<MessageComponentInteractionData>
    with MessageResponse<MessageComponentInteractionData>, ModalResponse<MessageComponentInteractionData> {
  /// {@macro message_component_interaction}
  /// @nodoc
  MessageComponentInteraction({
    required super.manager,
    required super.id,
    required super.applicationId,
    required super.type,
    required super.data,
    required super.guildId,
    required super.channel,
    required super.channelId,
    required super.member,
    required super.user,
    required super.token,
    required super.version,
    required super.message,
    required super.appPermissions,
    required super.locale,
    required super.guildLocale,
    required super.entitlements,
    required super.authorizingIntegrationOwners,
    required super.context,
    required super.attachmentSizeLimit,
  });

  bool? _didUpdateMessage;

  @override
  Future<InteractionCallbackResponse?> acknowledge({bool? updateMessage, bool? isEphemeral, bool? withResponse}) async {
    assert(updateMessage != true || isEphemeral != true, 'Cannot set isEphemeral to true if updateMessage is set to true');

    if (_didAcknowledge) {
      throw AlreadyAcknowledgedError(this);
    }

    _didAcknowledge = true;
    _didUpdateMessage = updateMessage;
    _wasEphemeral = isEphemeral;

    if (updateMessage == true) {
      return manager.createResponse(id, token, InteractionResponseBuilder.deferredUpdateMessage(), withResponse: withResponse);
    } else {
      return manager.createResponse(id, token, InteractionResponseBuilder.deferredChannelMessage(isEphemeral: isEphemeral), withResponse: withResponse);
    }
  }

  @override
  Future<InteractionCallbackResponse?> respond(
    Builder<Message> builder, {
    bool? updateMessage,
    @Deprecated('Use MessageBuilder.flags instead') bool? isEphemeral,
    bool? withResponse,
  }) async {
    assert(updateMessage != true || isEphemeral != true, 'Cannot set isEphemeral to true if updateMessage is set to true');
    assert(updateMessage != true || builder is MessageUpdateBuilder, 'builder must be a MessageUpdateBuilder if updateMessage is true');
    assert(updateMessage == true || builder is MessageBuilder, 'builder must be a MessageBuilder if updateMessage is null or false');

    if (_didRespond) {
      throw AlreadyRespondedError(this);
    }

    if (!_didAcknowledge) {
      _didAcknowledge = true;
      _didRespond = true;
      _didUpdateMessage = updateMessage;
      _wasEphemeral = isEphemeral;

      if (updateMessage == true) {
        return manager.createResponse(id, token, InteractionResponseBuilder.updateMessage(builder as MessageUpdateBuilder), withResponse: withResponse);
      } else {
        // ignore: deprecated_member_use_from_same_package
        return manager.createResponse(id, token, InteractionResponseBuilder.channelMessage(builder as MessageBuilder, isEphemeral: isEphemeral),
            withResponse: withResponse);
      }
    } else {
      assert(updateMessage == _didUpdateMessage || updateMessage == null, 'Cannot change the value of updateMessage between acknowledge and respond');
      assert(isEphemeral == _wasEphemeral || isEphemeral == null, 'Cannot change the value of isEphemeral between acknowledge and respond');

      _didRespond = true;

      if (_didUpdateMessage == true) {
        await manager.updateOriginalResponse(token, builder as MessageUpdateBuilder);
      } else {
        await manager.createFollowup(token, builder as MessageBuilder);
      }
    }

    return null;
  }
}

/// {@template modal_submit_interaction}
/// A modal submit interaction.
/// {@endtemplate}
class ModalSubmitInteraction extends Interaction<ModalSubmitInteractionData> with MessageResponse<ModalSubmitInteractionData> {
  /// {@macro modal_submit_interaction}
  /// @nodoc
  ModalSubmitInteraction({
    required super.manager,
    required super.id,
    required super.applicationId,
    required super.type,
    required super.data,
    required super.guildId,
    required super.channel,
    required super.channelId,
    required super.member,
    required super.user,
    required super.token,
    required super.version,
    required super.message,
    required super.appPermissions,
    required super.locale,
    required super.guildLocale,
    required super.entitlements,
    required super.authorizingIntegrationOwners,
    required super.context,
    required super.attachmentSizeLimit,
  });
}

/// {@template application_command_autocomplete_interaction}
/// An application command autocomplete interaction.
/// {@endtemplate}
class ApplicationCommandAutocompleteInteraction extends Interaction<ApplicationCommandInteractionData> {
  /// {@macro application_command_autocomplete_interaction}
  /// @nodoc
  ApplicationCommandAutocompleteInteraction({
    required super.manager,
    required super.id,
    required super.applicationId,
    required super.type,
    required super.data,
    required super.guildId,
    required super.channel,
    required super.channelId,
    required super.member,
    required super.user,
    required super.token,
    required super.version,
    required super.message,
    required super.appPermissions,
    required super.locale,
    required super.guildLocale,
    required super.entitlements,
    required super.authorizingIntegrationOwners,
    required super.context,
    required super.attachmentSizeLimit,
  });

  /// Send a response to this interaction.
  Future<void> respond(List<CommandOptionChoiceBuilder<dynamic>> builders) =>
      manager.createResponse(id, token, InteractionResponseBuilder.autocompleteResult(builders));
}

/// The type of an interaction.
final class InteractionType extends EnumLike<int, InteractionType> {
  static const ping = InteractionType(1);
  static const applicationCommand = InteractionType(2);
  static const messageComponent = InteractionType(3);
  static const applicationCommandAutocomplete = InteractionType(4);
  static const modalSubmit = InteractionType(5);

  /// @nodoc
  const InteractionType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  InteractionType.parse(int value) : this(value);
}

/// {@template application_command_interaction_data}
/// The data sent in an [ApplicationCommandInteraction] or an [ApplicationCommandAutocompleteInteraction].
/// {@endtemplate}
class ApplicationCommandInteractionData with ToStringHelper {
  /// The ID of the command.
  final Snowflake id;

  /// The name of the command.
  final String name;

  /// The type of the command.
  final ApplicationCommandType type;

  /// Additional data about entities in the payload.
  final ResolvedData? resolved;

  /// A list of provided options.
  final List<InteractionOption>? options;

  /// The ID of the guild the command was registered in, or `null` if it was a global command.
  final Snowflake? guildId;

  /// The ID of the entity the command was invoked on.
  final Snowflake? targetId;

  /// {@macro application_command_interaction_data}
  /// @nodoc
  ApplicationCommandInteractionData({
    required this.id,
    required this.name,
    required this.type,
    required this.resolved,
    required this.options,
    required this.guildId,
    required this.targetId,
  });
}

/// {@template resolved_data}
/// A mapping of IDs to entities.
/// {@endtemplate}
class ResolvedData with ToStringHelper {
  /// A mapping of user ID to [User].
  final Map<Snowflake, User>? users;

  /// A mapping of member ID to [Member].
  final Map<Snowflake, Member>? members;

  /// A mapping of role ID to [Role].
  final Map<Snowflake, Role>? roles;

  /// A mapping of channel ID to [PartialChannel].
  final Map<Snowflake, PartialChannel>? channels;

  /// A mapping of message ID to [PartialMessage].
  final Map<Snowflake, PartialMessage>? messages;

  /// A mapping of attachment ID to [Attachment].
  final Map<Snowflake, Attachment>? attachments;

  /// {@macro resolved_data}
  /// @nodoc
  ResolvedData({
    required this.users,
    required this.members,
    required this.roles,
    required this.channels,
    required this.messages,
    required this.attachments,
  });
}

/// {@template interaction_option}
/// The value of a command option passed in an [ApplicationCommandInteraction].
/// {@endtemplate}
class InteractionOption with ToStringHelper {
  /// The name of the option.
  final String name;

  /// The type of the option.
  final CommandOptionType type;

  /// The value of the option provided by the user.
  final dynamic value;

  /// A list of sub-options if this option is a subcommand or subcommand group.
  final List<InteractionOption>? options;

  /// Whether the user is focusing this option.
  final bool? isFocused;

  /// {@macro interaction_option}
  /// @nodoc
  InteractionOption({
    required this.name,
    required this.type,
    required this.value,
    required this.options,
    required this.isFocused,
  });
}

/// {@template message_component_interaction_data}
/// The data sent in a [MessageComponentInteraction].
/// {@endtemplate}
class MessageComponentInteractionData with ToStringHelper {
  /// The custom ID of the component that was used.
  final String customId;

  /// The type of component that was used.
  final MessageComponentType type;

  /// A list of values provided if the component was a [SelectMenuComponent].
  final List<String>? values;

  /// Additional data about entities in the payload.
  final ResolvedData? resolved;

  /// {@macro message_component_interaction_data}
  /// @nodoc
  MessageComponentInteractionData({required this.customId, required this.type, required this.values, required this.resolved});
}

/// {@template modal_submit_interaction_data}
/// The data sent in a [ModalSubmitInteraction].
/// {@endtemplate}
class ModalSubmitInteractionData with ToStringHelper {
  /// The custom ID of the modal.
  final String customId;

  /// A list of components in the modal.
  final List<MessageComponent> components;

  /// {@macro modal_submit_interaction_data}
  /// @nodoc
  ModalSubmitInteractionData({required this.customId, required this.components});
}

/// An unknown interaction.
class UnknownInteraction extends Interaction<void> {
  /// @nodoc
  UnknownInteraction({
    required super.manager,
    required super.id,
    required super.applicationId,
    required super.type,
    required super.guildId,
    required super.channel,
    required super.channelId,
    required super.member,
    required super.user,
    required super.token,
    required super.version,
    required super.message,
    required super.appPermissions,
    required super.locale,
    required super.guildLocale,
    required super.entitlements,
    required super.authorizingIntegrationOwners,
    required super.context,
    required super.attachmentSizeLimit,
  }) : super(data: null);
}

/// An interaction callback response.
class InteractionCallbackResponse with ToStringHelper {
  /// The interaction object associated with the interaction response.
  final InteractionCallback interaction;

  /// The resource that was created by the interaction response.
  final InteractionResource? resource;

  /// @nodoc
  const InteractionCallbackResponse({
    required this.interaction,
    required this.resource,
  });
}

/// An interaction callback.
class InteractionCallback with ToStringHelper {
  /// The id of the interaction.
  final Snowflake id;

  /// The type of the interaction.
  final InteractionType type;

  /// The instance id of the Activity if one was launched or joined.
  final String? activityInstanceId;

  /// The id of the message that was created by the interaction.
  final Snowflake? responseMessageId;

  /// Whether or not the message is in a loading state.
  final bool? responseMessageLoading;

  /// Whether or not the response message was ephemeral.
  final bool? responseMessageEphemeral;

  /// @nodoc
  const InteractionCallback({
    required this.activityInstanceId,
    required this.id,
    required this.responseMessageEphemeral,
    required this.responseMessageId,
    required this.responseMessageLoading,
    required this.type,
  });
}

/// An interaction resource.
class InteractionResource with ToStringHelper {
  /// The interaction callback type.
  final InteractionCallbackType type;

  /// Represents the Activity launched by this interaction.
  ///
  /// * Only present if [type] is [InteractionCallbackType.launchActivity].
  final InteractionCallbackActivityInstanceResource? activityInstance;

  /// The message created by the interaction.
  ///
  /// * Only present if [type] is either [InteractionCallbackType.channelMessageWithSource] or [InteractionCallbackType.updateMessage].
  final Message? message;

  /// @nodoc
  const InteractionResource({
    required this.type,
    required this.activityInstance,
    required this.message,
  });
}

class InteractionCallbackActivityInstanceResource with ToStringHelper {
  /// The instance id of the Activity if one was launched or joined.
  final String id;

  /// @nodoc
  const InteractionCallbackActivityInstanceResource({
    required this.id,
  });
}
