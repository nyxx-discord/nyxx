part of discord;

/// An OAuth2 application.
class OAuth2Application extends _BaseObj {
  /// The app's description.
  String description;

  /// The app's icon hash.
  String icon;

  /// The app's ID.
  String id;

  /// The app's name.
  String name;

  /// The app's RPC origins.
  List<String> rpcOrigins;

  /// A timestamp for when the app was created.
  DateTime createdAt;

  OAuth2Application._new(Client client, Map<String, dynamic> data)
      : super(client) {
    this.description = this._map['description'] = data['description'];
    this.icon = this._map['icon'] = data['icon'];
    this.id = this._map['id'] = data['id'];
    this.name = this._map['name'] = data['name'];
    this.rpcOrigins =
        this._map['rpcOrigins'] = data['rpcOrigins'] as List<String>;
    this.createdAt =
        this._map['createdAt'] = this._client._util.getDate(this.id);
    this._map['key'] = this.id;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
