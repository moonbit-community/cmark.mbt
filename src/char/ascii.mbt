///|
pub fn to_ascii_lower(c : Char) -> Char {
  guard c.is_ascii_uppercase() else { c }
  (c.to_int() + 32).unsafe_to_char()
}

///|
pub fn to_ascii_upper(c : Char) -> Char {
  guard c.is_ascii_lowercase() else { c }
  (c.to_int() - 32).unsafe_to_char()
}

///|
pub fn is_ascii_blank(c : Char) -> Bool {
  c is (' ' | '\t')
}

///|
pub fn is_ascii_whitespace(c : Char) -> Bool {
  c is (' ' | '\u{A}'..='\u{D}')
}

///|
pub fn is_ascii_control(c : Char) -> Bool {
  c is ('\u{0}'..='\u{1F}' | '\u{7F}')
}

///|
pub fn is_ascii_punctuation(c : Char) -> Bool {
  c is ('!'..='/' | ':'..='@' | '['..='`' | '{'..='~')
}

///|
pub fn is_ascii_graphic(c : Char) -> Bool {
  c is ('!'..='~')
}

///|
pub fn is_ascii_alphanum(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c.is_ascii_digit()
}

///|
pub fn ascii_digit_to_int(c : Char) -> Int {
  guard c.is_ascii_digit()
  c.to_int() - '0'.to_int()
}

///|
pub fn ascii_octdigit_to_int(c : Char) -> Int {
  guard c.is_ascii_octdigit()
  c.to_int() - '0'.to_int()
}

///|
pub fn ascii_hexdigit_to_int(c : Char) -> Int {
  match c {
    '0'..='9' => c.to_int() - '0'.to_int() + 0x0
    'A'..='F' => c.to_int() - 'A'.to_int() + 0xa
    'a'..='f' => c.to_int() - 'a'.to_int() + 0xa
    _ => panic()
  }
}
