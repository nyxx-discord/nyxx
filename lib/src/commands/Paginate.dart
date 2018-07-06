part of nyxx.commands;

class Paginate {
  List<String> _paginateData;
  Channel _channel;

  Emoji next = UnicodeEmoji.track_next;
  Emoji prev = UnicodeEmoji.track_previous;

  int _current = 0;

  Paginate(this._paginateData, this._channel);

  Future<Message> create() async {}
}
