part of nyxx;

class Snowflake {
  /// Full snowflake id
  String id;

  /// Time when id was created.
  DateTime timestamp;

  /// Internal worker id
  int workerId;

  /// Internal process id
  int processId;

  /// For every ID that is generated on that process, this number is incremented
  int sequence;

  /// Creates new instance of [Snowflake].
  Snowflake(this.id) {
    int _unusedBits = 0;
    int _timestampBits = 42;
    int _workerIdBits = 5;
    int _processIdBits = 5;
    int _sequenceBits = 12;

    int _maxWorkerId = -1 ^ (-1 << _workerIdBits); // 2^5-1
    int _maxProcessId = -1 ^ (-1 << _processIdBits); // 2^5-1
    int _maxSequence = -1 ^ (-1 << _sequenceBits); // 2^12-1

    int _timestampShift = _sequenceBits + _workerIdBits + _processIdBits;
    int _workerIdShift = _sequenceBits + _processIdBits;
    int _processShift = _sequenceBits;

    int _epoch = 1420070400000;
    int tmpId = int.parse(id);

    var tmp =
        ((tmpId & _diode(_unusedBits, _timestampBits)) >> _timestampShift);
    timestamp = new DateTime.fromMillisecondsSinceEpoch(tmp + _epoch);
    workerId = (tmpId & _diode(_unusedBits + _timestampBits, _workerIdBits)) >>
        _workerIdShift;
    processId = (tmpId &
            _diode(_unusedBits + _timestampBits + _workerIdBits,
                _processIdBits)) >>
        _processShift;
    sequence = (tmpId &
        _diode(_unusedBits + _timestampBits + _workerIdBits + _processIdBits,
            _sequenceBits));
  }

  int _diode(int offset, int length) {
    int lb = 64 - offset;
    int rb = 64 - (offset + length);
    return (-1 << lb) ^ (-1 << rb);
  }

  String toString() => id;
}
