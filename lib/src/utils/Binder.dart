import 'package:nyxx/nyxx.dart';
import 'Util.dart' as utils;

import 'dart:async';

/// Class used to bind method to Stream
class Bind {
  /// Name of stream to bind
  final String streamName;

  const Bind(String name): streamName = "Symbol(\"$name\")";
}