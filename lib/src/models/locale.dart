import 'package:nyxx/src/utils/enum_like.dart';

/// A language locale available in the Discord client.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/reference#locales
final class Locale extends EnumLike<String> {
  static const Locale id = Locale._('id', 'Indonesian', 'Bahasa Indonesia');
  static const Locale da = Locale._('da', 'Danish', 'Dansk');
  static const Locale de = Locale._('de', 'German', 'Deutsch');
  static const Locale enGb = Locale._('en-GB', 'English, UK', 'English, UK');
  static const Locale enUs = Locale._('en-US', 'English, US', 'English, US');
  static const Locale esEs = Locale._('es-ES', 'Spanish', 'Español');
  static const Locale es419 = Locale._('es-419', 'Spanish, LATAM', 'Español, LATAM');
  static const Locale fr = Locale._('fr', 'French', 'Français');
  static const Locale hr = Locale._('hr', 'Croatian', 'Hrvatski');
  static const Locale it = Locale._('it', 'Italian', 'Italiano');
  static const Locale lt = Locale._('lt', 'Lithuanian', 'Lietuviškai');
  static const Locale hu = Locale._('hu', 'Hungarian', 'Magyar');
  static const Locale nl = Locale._('nl', 'Dutch', 'Nederlands');
  static const Locale no = Locale._('no', 'Norwegian', 'Norsk');
  static const Locale pl = Locale._('pl', 'Polish', 'Polski');
  static const Locale ptBr = Locale._('pt-BR', 'Portuguese, Brazilian', 'Português do Brasil');
  static const Locale ro = Locale._('ro', 'Romanian, Romania', 'Română');
  static const Locale fi = Locale._('fi', 'Finnish', 'Suomi');
  static const Locale svSe = Locale._('sv-SE', 'Swedish', 'Svenska');
  static const Locale vi = Locale._('vi', 'Vietnamese', 'Tiếng Việt');
  static const Locale tr = Locale._('tr', 'Turkish', 'Türkçe');
  static const Locale cs = Locale._('cs', 'Czech', 'Čeština');
  static const Locale el = Locale._('el', 'Greek', 'Ελληνικά');
  static const Locale bg = Locale._('bg', 'Bulgarian', 'български');
  static const Locale ru = Locale._('ru', 'Russian', 'Pусский');
  static const Locale uk = Locale._('uk', 'Ukrainian', 'Українська');
  static const Locale hi = Locale._('hi', 'Hindi', 'हिन्दी');
  static const Locale th = Locale._('th', 'Thai', 'ไทย');
  static const Locale zhCn = Locale._('zh-CN', 'Chinese, China', '中文');
  static const Locale ja = Locale._('ja', 'Japanese', '日本語');
  static const Locale zhTw = Locale._('zh-TW', 'Chinese, Taiwan', '繁體中文');
  static const Locale ko = Locale._('ko', 'Korean', '한국어');

  static const List<Locale> values = [
    id,
    da,
    de,
    enGb,
    enUs,
    esEs,
    es419,
    fr,
    hr,
    it,
    lt,
    hu,
    nl,
    no,
    pl,
    ptBr,
    ro,
    fi,
    svSe,
    vi,
    tr,
    cs,
    el,
    bg,
    ru,
    uk,
    hi,
    th,
    zhCn,
    ja,
    zhTw,
    ko,
  ];

  /// The identifier for this locale.
  final String identifier;

  /// The english name of this locale.
  final String name;

  /// The native name of this locale.
  final String nativeName;

  const Locale._(this.identifier, this.name, this.nativeName) : super(identifier);

  /// Parse a string into a locale.
  ///
  /// [identifier] must be a string containing an identifier matching [Locale.identifier] for one of
  /// the listed locales.
  factory Locale.parse(String identifier) => parseEnum(values, identifier);
}
