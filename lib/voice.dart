///  Nyxx DISCORD API wrapper for Dart
///  Voice sublibrary wrapps all tool and logic needed to interact with voice.
///  Allows to connect to channel and play music using [Lavalink](https://github.com/Frederikam/Lavalink)
library nyxx.voice;

import 'nyxx.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

part 'src/voice/VoiceService.dart';
part 'src/voice/Player.dart';

part 'src/voice/events/TrackError.dart';
part 'src/voice/events/TrackEndEvent.dart';
part 'src/voice/events/TrackExceptionEvent.dart';
part 'src/voice/events/TrackStuckEvent.dart';
part 'src/voice/events/PlayerUpdateEvent.dart';

part 'src/voice/opcodes/SimpleOp.dart';
part 'src/voice/opcodes/OpPause.dart';
part 'src/voice/opcodes/OpSeek.dart';
part 'src/voice/opcodes/OpVolume.dart';
part 'src/voice/opcodes/OpPlay.dart';
part 'src/voice/opcodes/OpVoiceUpdate.dart';
part 'src/voice/opcodes/Opcode4.dart';

part 'src/voice/objects/Stats.dart';
part 'src/voice/objects/Track.dart';
part 'src/voice/objects/TrackResponse.dart';
part 'src/voice/objects/Playlist.dart';
part 'src/voice/objects/Entity.dart';
