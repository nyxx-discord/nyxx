library nyxx.voice;

import 'nyxx.dart';

import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm.dart' show vmTransportPlatform;
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'src/Util.dart' as util;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

part 'src/voice/VoiceManager.dart';
part 'src/voice/Player.dart';

part 'src/voice/events/PlayerUpdateEvent.dart';

part 'src/voice/opcodes/OpStop.dart';
part 'src/voice/opcodes/OpPause.dart';
part 'src/voice/opcodes/OpPlay.dart';
part 'src/voice/opcodes/OpVoiceUpdate.dart';
part 'src/voice/opcodes/Opcode4.dart';

part 'src/voice/objects/Track.dart';
part 'src/voice/objects/TrackResponse.dart';
part 'src/voice/objects/Playlist.dart';
part 'src/voice/objects/Entity.dart';