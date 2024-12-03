///|
pub fn is_ascii(c : Char) -> Bool {
  c.to_int() < 128
}

///|
pub fn to_ascii_lower(c : Char) -> Char {
  if is_ascii_upper(c) {
    Char::from_int(c.to_int() + 32)
  } else {
    c
  }
}

///|
pub fn to_ascii_upper(c : Char) -> Char {
  if is_ascii_lower(c) {
    Char::from_int(c.to_int() - 32)
  } else {
    c
  }
}

///|
pub fn is_ascii_blank(c : Char) -> Bool {
  " \t".contains_char(c)
}

///|
pub fn is_ascii_whitespace(c : Char) -> Bool {
  " \t\x0A\x0B\x0C\x0D".contains_char(c)
}

///|
pub fn is_ascii_control(c : Char) -> Bool {
  ('\x00' <= c && c <= '\x1F') || c == '\x7F'
}

///|
pub fn is_ascii_punctuation(c : Char) -> Bool {
  ('!' <= c && c <= '/') ||
  (':' <= c && c <= '@') ||
  ('[' <= c && c <= '`') ||
  ('{' <= c && c <= '~')
}

///|
pub fn is_ascii_graphic(c : Char) -> Bool {
  '!' <= c && c <= '~'
}

///|
pub fn is_ascii_alphanum(c : Char) -> Bool {
  is_ascii_alpha(c) || is_ascii_digit(c)
}

///|
pub fn is_ascii_alpha(c : Char) -> Bool {
  is_ascii_upper(c) || is_ascii_lower(c)
}

///|
pub fn is_ascii_upper(c : Char) -> Bool {
  'A' <= c && c <= 'Z'
}

///|
pub fn is_ascii_lower(c : Char) -> Bool {
  'a' <= c && c <= 'z'
}

///|
pub fn is_ascii_digit(c : Char) -> Bool {
  '0' <= c && c <= '9'
}

///|
pub fn ascii_digit_to_int(c : Char) -> Int {
  match c {
    '0'..='9' => c.to_int() - '0'.to_int()
    _ => panic()
  }
}

///|
pub fn is_ascii_octdigit(c : Char) -> Bool {
  '0' <= c && c <= '7'
}

///|
pub fn ascii_octdigit_to_int(c : Char) -> Int {
  match c {
    '0'..='7' => c.to_int() - '0'.to_int()
    _ => panic()
  }
}

///|
pub fn is_ascii_hexdigit(c : Char) -> Bool {
  is_ascii_digit(c) || ('A' <= c && c <= 'F') || ('a' <= c && c <= 'f')
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
