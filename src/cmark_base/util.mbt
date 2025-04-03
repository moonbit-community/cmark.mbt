///|
fn char_is_atext_plus_dot(c : Char) -> Bool {
  @char.is_ascii_alphanum(c) ||
  c
  is ('!'
  | '#'
  | '$'
  | '%'
  | '&'
  | '\\'
  | '*'
  | '+'
  | '-'
  | '/'
  | '='
  | '?'
  | '^'
  | '_'
  | '`'
  | '|'
  | '{'
  | '}'
  | '~'
  | '.')
}
