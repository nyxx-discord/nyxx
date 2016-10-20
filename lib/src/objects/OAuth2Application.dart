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
    this.description = data['description'];
    this.icon = data['icon'];
    this.id = data['id'];
    this.name = data['name'];
    this.rpcOrigins = data['rpcOrigins'] as List<String>;
    this.createdAt = Util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
