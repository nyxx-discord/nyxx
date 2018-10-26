///  Nyxx Discord API for Dart
///  Lavalink sublibrary
///
///  Lavalink sublibrary wraps all tools and logic needed to interact with voice.
///  Allows to connect to channel and play music via [Lavalink](https://github.com/Frederikam/Lavalink)
library nyxx.lavalink;

import 'nyxx.dart';
import 'package:logging/logging.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

part 'src/lavalink/LavalinkManager.dart';
part 'src/lavalink/LavalinkPlayer.dart';

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
