import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionResponseBuilder', () {
    test('autocompleteResult', () {
      expect(
        InteractionResponseBuilder.autocompleteResult([CommandOptionChoiceBuilder(name: 'foo', value: 'bar')]).build(),
        equals({
          'type': 8,
          'data': {
            'choices': [
              {'name': 'foo', 'value': 'bar'},
            ]
          }
        }),
      );
    });
  });
}
