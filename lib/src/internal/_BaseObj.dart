part of discord;

class _BaseObj {
  Client _client;
  Map<String, dynamic> _map = <String, dynamic>{};

  _BaseObj(this._client);
}

class _UnsetString implements String {}
