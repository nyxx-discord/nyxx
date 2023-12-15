/// A language locale available in the Discord client.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/reference#locales
enum Locale {
  id._('id', 'Indonesian', 'Bahasa Indonesia'),
  da._('da', 'Danish', 'Dansk'),
  de._('de', 'German', 'Deutsch'),
  enGb._('en-GB', 'English, UK', 'English, UK'),
  enUs._('en-US', 'English, US', 'English, US'),
  esEs._('es-ES', 'Spanish', 'Español'),
  es419._('es-419', 'Spanish, LATAM', 'Español, LATAM'),
  fr._('fr', 'French', 'Français'),
  hr._('hr', 'Croatian', 'Hrvatski'),
  it._('it', 'Italian', 'Italiano'),
  lt._('lt', 'Lithuanian', 'Lietuviškai'),
  hu._('hu', 'Hungarian', 'Magyar'),
  nl._('nl', 'Dutch', 'Nederlands'),
  no._('no', 'Norwegian', 'Norsk'),
  pl._('pl', 'Polish', 'Polski'),
  ptBr._('pt-BR', 'Portuguese, Brazilian', 'Português do Brasil'),
  ro._('ro', 'Romanian, Romania', 'Română'),
  fi._('fi', 'Finnish', 'Suomi'),
  svSe._('sv-SE', 'Swedish', 'Svenska'),
  vi._('vi', 'Vietnamese', 'Tiếng Việt'),
  tr._('tr', 'Turkish', 'Türkçe'),
  cs._('cs', 'Czech', 'Čeština'),
  el._('el', 'Greek', 'Ελληνικά'),
  bg._('bg', 'Bulgarian', 'български'),
  ru._('ru', 'Russian', 'Pусский'),
  uk._('uk', 'Ukrainian', 'Українська'),
  hi._('hi', 'Hindi', 'हिन्दी'),
  th._('th', 'Thai', 'ไทย'),
  zhCn._('zh-CN', 'Chinese, China', '中文'),
  ja._('ja', 'Japanese', '日本語'),
  zhTw._('zh-TW', 'Chinese, Taiwan', '繁體中文'),
  ko._('ko', 'Korean', '한국어');

  /// The identifier for this locale.
  final String identifier;

  /// The english name of this locale.
  final String name;

  /// The native name of this locale.
  final String nativeName;

  const Locale._(this.identifier, this.name, this.nativeName);

  /// Parse a string into a locale.
  ///
  /// [identifier] must be a string containing an identifier matching [Locale.identifier] for one of
  /// the listed locales.
  factory Locale.parse(String identifier) => Locale.values.firstWhere(
        (locale) => locale.identifier == identifier,
        orElse: () => throw FormatException('Unknown Locale', identifier),
      );

  @override
  String toString() => 'Locale($identifier)';
}
