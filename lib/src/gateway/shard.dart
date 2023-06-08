import 'dart:async';
import 'dart:isolate';

import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/gateway/message.dart';
import 'package:nyxx/src/gateway/shard_runner.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/models/snowflake.dart';

// TODO: Handle ErrorReceived events
class Shard extends Stream<ShardMessage> implements StreamSink<GatewayMessage> {
  final int id;

  final Isolate isolate;

  final Stream<dynamic> receiveStream;

  final SendPort sendPort;

  final Completer<void> _doneCompleter = Completer();

  Shard(this.id, this.isolate, this.receiveStream, this.sendPort) {
    drain().then((value) {
      // Can happen if the shard closes unexpectedly.
      // Prevents further calls to close() from attempting to add events.
      if (!_doneCompleter.isCompleted) {
        _doneCompleter.complete(value);
      }
    });
  }

  static Future<Shard> connect(int id, int totalShards, GatewayApiOptions apiOptions, Uri connectionUri) async {
    final receivePort = ReceivePort('Shard #$id message stream (main)');
    final receiveStream = receivePort.asBroadcastStream();

    final isolate = await Isolate.spawn(
      _isolateMain,
      _IsolateSpawnData(
        totalShards: totalShards,
        id: id,
        apiOptions: apiOptions,
        originalConnectionUri: connectionUri,
        sendPort: receivePort.sendPort,
      ),
    );

    final exitPort = ReceivePort('Shard #$id exit listener');
    isolate.addOnExitListener(exitPort.sendPort);
    exitPort.listen((_) {
      receivePort.close();
      exitPort.close();
    });

    final sendPort = await receiveStream.first as SendPort;

    return Shard(id, isolate, receiveStream, sendPort);
  }

  void updateVoiceState(Snowflake guildId, GatewayVoiceStateBuilder builder) {
    add(Send(opcode: Opcode.voiceStateUpdate, data: {
      'guild_id': guildId.toString(),
      ...builder.build(),
    }));
  }

  @override
  void add(GatewayMessage event) => sendPort.send(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => throw UnimplementedError();

  @override
  Future<void> addStream(Stream<GatewayMessage> stream) => throw UnimplementedError();

  @override
  Future<void> close() {
    if (_doneCompleter.isCompleted) {
      return _doneCompleter.future;
    }

    Future<void> doClose() async {
      add(Dispose());

      // Wait for disconnection confirmation
      await firstWhere((message) => message is Disconnecting);

      // Give the isolate time to shut down cleanly, but kill it if it takes too long.
      try {
        await drain().timeout(const Duration(seconds: 5));
      } on TimeoutException {
        // TODO: Log a warning here
        isolate.kill(priority: Isolate.immediate);
      }
    }

    _doneCompleter.complete(doClose());
    return _doneCompleter.future;
  }

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  StreamSubscription<ShardMessage> listen(
    void Function(ShardMessage event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return receiveStream.cast<ShardMessage>().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class _IsolateSpawnData extends ShardData {
  final SendPort sendPort;

  _IsolateSpawnData({
    required super.totalShards,
    required super.id,
    required super.apiOptions,
    required super.originalConnectionUri,
    required this.sendPort,
  });
}

void _isolateMain(_IsolateSpawnData data) async {
  final receivePort = ReceivePort('Shard #${data.id} message stream (isolate)');
  data.sendPort.send(receivePort.sendPort);

  final runner = ShardRunner(data);

  runner.run(receivePort.cast<GatewayMessage>()).listen(
        data.sendPort.send,
        onDone: () => receivePort.close(),
      );
}
