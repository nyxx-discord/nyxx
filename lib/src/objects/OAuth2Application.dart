import '../objects.dart';

/// An OAuth2 application.
class OAuth2Application {
  /// The app's description.
  String description;

  /// The app's icon hash.
  String icon;

  /// The app's ID.
  String id;

  /// The app's name.
  String name;

  /// The app's RPC origins.
  List rpcOrigins;

  /// A timestamp for when the app was created.
  double createdAt;

  OAuth2Application(Map data) {
    this.description = data['description'];
    this.icon = data['icon'];
    this.id = data['id'];
    this.name = data['name'];
    this.rpcOrigins = data['rpcOrigins'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
  }
}
