import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/manager_mixin.dart';

class MockNyxx with Mock, ManagerMixin implements NyxxRest {}
