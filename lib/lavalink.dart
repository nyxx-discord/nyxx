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

part 'src/lavalink/VoiceService.dart';
part 'src/lavalink/Player.dart';

part 'src/lavalink/events/TrackError.dart';
part 'src/lavalink/events/TrackEndEvent.dart';
part 'src/lavalink/events/TrackExceptionEvent.dart';
part 'src/lavalink/events/TrackStuckEvent.dart';
part 'src/lavalink/events/PlayerUpdateEvent.dart';

part 'src/lavalink/opcodes/SimpleOp.dart';
part 'src/lavalink/opcodes/OpPause.dart';
part 'src/lavalink/opcodes/OpSeek.dart';
part 'src/lavalink/opcodes/OpVolume.dart';
part 'src/lavalink/opcodes/OpPlay.dart';
part 'src/lavalink/opcodes/OpVoiceUpdate.dart';
part 'src/lavalink/opcodes/Opcode4.dart';

part 'src/lavalink/objects/Stats.dart';
part 'src/lavalink/objects/Track.dart';
part 'src/lavalink/objects/TrackResponse.dart';
part 'src/lavalink/objects/Playlist.dart';
part 'src/lavalink/objects/Entity.dart';
