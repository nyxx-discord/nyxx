part of nyxx.commands;

class Utils {
  /// Gets [Symbol]s 'name'
  static String getSymbolName(Symbol symbol) {
    return symbol
        .toString()
        .substring(6)
        .replaceAll("\"", "")
        .replaceAll("(", "")
        .replaceAll(")", "");
  }
}