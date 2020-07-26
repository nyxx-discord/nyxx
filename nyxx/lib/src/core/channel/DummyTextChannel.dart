part of nyxx;

class DummyTextChannel extends Channel with MessageChannel, ISend implements ITextChannel {
  DummyTextChannel._new(Map<String, dynamic> raw, int type, Nyxx client) : super._new(raw, type, client);
}