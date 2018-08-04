library nyxx.voice;

import 'nyxx.dart';

import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

part 'src/voice/VoiceService.dart';
part 'src/voice/Player.dart';

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