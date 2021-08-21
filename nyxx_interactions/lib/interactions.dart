library nyxx_interactions;

import "dart:async";
import "dart:collection";
import "dart:convert";

import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";

// Root
part "src/Interactions.dart";

// Models
part "src/models/SlashCommand.dart";
part "src/models/Interaction.dart";
part "src/models/InteractionOption.dart";
part "src/models/ArgChoice.dart";
part "src/models/InteractionDataResolved.dart";
part "src/models/SlashCommandType.dart";

// Builders
part "src/builders/ArgChoiceBuilder.dart";
part "src/builders/CommandOptionBuilder.dart";
part "src/builders/SlashCommandBuilder.dart";
part "src/builders/ComponentBuilder.dart";
part "src/builders/CommandPermissionBuilder.dart";

// Command Args
part "src/models/CommandOption.dart";

// Internal
part "src/internal/_EventController.dart";
part "src/internal/InteractionEndpoints.dart";
part "src/internal/utils.dart";

// Events
part "src/events/InteractionEvent.dart";

// Exceptions
part "src/exceptions/InteractionExpired.dart";
part "src/exceptions/AlreadyResponded.dart";
part "src/exceptions/ResponseRequired.dart";

/// Typedef of api response
typedef RawApiMap = Map<String, dynamic>;
