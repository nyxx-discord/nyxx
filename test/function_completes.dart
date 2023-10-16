import 'package:test/test.dart' hide completes;
import 'package:test/test.dart' as test show completes;
import 'package:matcher/src/expect/async_matcher.dart' show AsyncMatcher;

/// A simple wrapper around [test.completes] that invokes functions and tests their result instead of failing.
const completes = _FunctionCompletes();

class _FunctionCompletes extends AsyncMatcher {
  const _FunctionCompletes();

  @override
  matchAsync(item) {
    if (item is Function()) {
      item = item();
    }

    return (test.completes as AsyncMatcher).matchAsync(item);
  }

  @override
  Description describe(Description description) => test.completes.describe(description);
}
