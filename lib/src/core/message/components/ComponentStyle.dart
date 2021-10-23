import 'package:nyxx/src/utils/IEnum.dart';

/// Style for a button.
class ComponentStyle extends IEnum<int> {
  /// A blurple button
  static const primary = ComponentStyle._create(1);

  /// A grey button
  static const secondary = ComponentStyle._create(2);

  /// A green button
  static const success = ComponentStyle._create(3);

  /// A red button
  static const danger = ComponentStyle._create(4);

  /// A button that navigates to a URL
  static const link = ComponentStyle._create(5);

  /// Creates instance of [ComponentStyle]
  ComponentStyle.from(int value) : super(value);
  const ComponentStyle._create(int value) : super(value);
}
