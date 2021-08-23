library nyxx_interactions;

import "dart:async";
import 'dart:convert';

import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";

// Root
part "src/Interactions.dart";
// Builders
part "src/builders/ArgChoiceBuilder.dart";
part "src/builders/CommandOptionBuilder.dart";
part "src/builders/CommandPermissionBuilder.dart";
part "src/builders/ComponentBuilder.dart";
part "src/builders/SlashCommandBuilder.dart";
// Events
part "src/events/InteractionEvent.dart";
part "src/exceptions/AlreadyResponded.dart";
part "src/exceptions/AlreadyResponded.dart";
// Exceptions
part "src/exceptions/InteractionExpired.dart";
part "src/exceptions/ResponseRequired.dart";
part "src/exceptions/ResponseRequired.dart";
// Internal
part "src/internal/_EventController.dart";
part "src/internal/utils.dart";
part "src/models/ArgChoice.dart";
// Command Args
part "src/models/CommandOption.dart";
part "src/models/Interaction.dart";
part "src/models/InteractionOption.dart";
// Models
part "src/models/SlashCommand.dart";

/// Typedef of api response
typedef RawApiMap = Map<String, dynamic>;
