import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/snowflake.dart';

// ASCII encoded "nyxx"
const sentinelInteger = 0x6E797878;

// ESC-"nyxx"
const sentinelString = '\u{1B}nyxx';

const sentinelDuration = _SentinelDuration();

class _SentinelDuration implements Duration {
  const _SentinelDuration();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelSnowflake = _SentinelSnowflake();

class _SentinelSnowflake implements Snowflake {
  const _SentinelSnowflake();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelDefaultReaction = _SentinelDefaultReaction();

class _SentinelDefaultReaction implements DefaultReaction {
  const _SentinelDefaultReaction();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelList = _SentinelList();

class _SentinelList implements List<Never> {
  const _SentinelList();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelImageBuilder = _SentinelImageBuilder();

class _SentinelImageBuilder implements ImageBuilder {
  const _SentinelImageBuilder();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
