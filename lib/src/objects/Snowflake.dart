part of nyxx;

/// [Snowflake] represents id structure which is used by discord.
/// [id] is actual id of entity which holds [Snowflake]
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

  @override
  String toString() => id;

  @override
  bool operator ==(other) {
    if (other is Snowflake) return other.id == this.id;
    if (other is String) return other == this.id;

    return false;
  }

  @override
  int get hashCode => this.id.hashCode;
}
