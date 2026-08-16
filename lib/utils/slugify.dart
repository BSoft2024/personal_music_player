/// Turns a song title into a safe filename (no extension).
/// Example: "Dämmerung" → "dammerung"
///          "Fortun Okt: A Lydian" → "fortun_okt_a_lydian"
String slugify(String input) {
  String s = input.trim().toLowerCase();

  const Map<String, String> replacements = {
    'ə': 'e',
    'ő': 'o',
    'ö': 'o',
    'ü': 'u',
    'ä': 'a',
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ñ': 'n',
    'ç': 'c',
    'ß': 'ss',
    '–': '-',
    '—': '-',
    ':': '',
    '/': '',
    '\\': '',
    '?': '',
    '!': '',
    '\'': '',
    '"': '',
    '(': '',
    ')': '',
    '[': '',
    ']': '',
    '{': '',
    '}': '',
    ',': '',
    '.': '',
    ';': '',
    '&': 'and',
    '+': 'plus',
  };

  replacements.forEach((k, v) {
    s = s.replaceAll(k, v);
  });

  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  s = s.replaceAll(RegExp(r'_+'), '_');
  s = s.replaceAll(RegExp(r'^_|_$'), '');

  return s;
}
