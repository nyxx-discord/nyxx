import 'package:nyxx/nyxx.dart';
import 'package:test/fake.dart';

class EnumMock extends IEnum<String> with Fake {
  EnumMock(String value) : super(value);
}
