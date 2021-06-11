import 'dart:convert';

import "package:nyxx_lavalink/lavalink.dart";

void main() async {
  final json = '{"hello": "world"}' as dynamic;

  final decoded = jsonDecode(json as String);

  print(decoded);
}