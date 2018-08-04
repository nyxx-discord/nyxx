import 'dart:async';

/// Merges list of stream into one stream
Stream<T> merge<T>(List<Stream<T>> streams) {
  int _open = streams.length;
  var c = new StreamController<T>();
  for (var stream in streams) {
    stream.listen(c.add)
      ..onError(c.addError)
      ..onDone(() {
        if (--_open == 0) {
          c.close();
        }
      });
  }
  return c.stream;
}

/// Converts RGB hex string into int value
int RGBtoInt(String RGB) {
  int R = int.parse(RGB.substring(0, 3), radix: 16);
  int G = int.parse(RGB.substring(3, 5), radix: 16);
  int B = int.parse(RGB.substring(5), radix: 16);

  return B * 65536 + G * 256 + R;
}

/// Splits string based on desied lenght
Iterable<String> split(String str, int length) sync* {
  int last = 0;
  while (last < str.length && ((last + length) < str.length)) {
    yield str.substring(last, last + length);
    last += length;
  }
  yield str.substring(last, str.length);
}

/// Splits string bases on given lengt but it preserves words - splits
/// only on whitespace.
Iterable<String> split300iq(String str, int length) sync* {
  int last = 0;
  while (last < str.length && ((last + length) < str.length)) {
    if(str[last + length] == " ") {
      yield str.substring(last, last + length);
      last += length;
    } else {
      var nextWh = str.indexOf(" ", last + length);
      yield str.substring(last, nextWh);
      last += nextWh;
    }
  }
  yield str.substring(last, str.length);
}

/// Splits string based on number of wanted substrings
Iterable<String> splitEqually(String str, int pieces) {
  int len = (str.length / pieces).round();

  return split(str, len);
}
