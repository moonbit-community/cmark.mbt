// Unicode character classification with platform-specific implementations
//
// The JS backend calls into the engine's own Unicode data, so the
// multi-megabyte static tables of `moonbit-community/unicode` are not shipped
// to the browser.
//
// IMPLEMENTATION DIFFERENCES:
//
// 1. is_whitespace:
//    - JS backend: Uses \s regex, matches only ASCII whitespace characters
//      (space, tab, newline, carriage return, form feed, vertical tab)
//    - Non-JS backend: Uses the Unicode White_Space property (~25 characters)
//      including U+2028 (Line Separator), U+2029 (Paragraph Separator), etc.
//
// 2. is_punctuation:
//    - JS backend: Uses \p{P} regex, depends on JS engine's Unicode version
//    - Non-JS backend: Uses the `moonbit-community/unicode` tables, i.e. one
//      fixed Unicode version (18.0.0)
//    - Both cover Unicode punctuation categories (Pc, Pd, Pe, Pf, Pi, Po, Ps)
//    - May differ for newly added punctuation in newer Unicode versions
//
// 3. is_unicode_punctuation (private): punctuation (P) or symbol (S)
//    categories, the CommonMark definition of punctuation for emphasis.
//    Same differences as is_punctuation.
//
// For CommonMark parsing, these differences have minimal impact since
// Markdown primarily uses ASCII whitespace and punctuation characters.

// JS backend implementation using JS FFI

///|
/// Check if a character is a Unicode whitespace
/// Uses JS regex \s for whitespace detection
/// Note: \s only matches ASCII whitespace, not full Unicode whitespace
#cfg(target="js")
pub fn is_whitespace(c : Char) -> Bool {
  is_whitespace_ffi(c.to_int())
}

///|
/// Check if a character is a Unicode punctuation
/// Uses JS Unicode property escapes for punctuation detection
#cfg(target="js")
pub fn is_punctuation(c : Char) -> Bool {
  is_punctuation_ffi(c.to_int())
}

///|
/// Check if a character is a
/// [Unicode punctuation character](https://spec.commonmark.org/0.31.2/#unicode-punctuation-character),
/// i.e. in the Unicode `P` (punctuation) or `S` (symbol) general categories.
#cfg(target="js")
fn is_unicode_punctuation(c : Char) -> Bool {
  is_unicode_punctuation_ffi(c.to_int())
}

///|
#cfg(target="js")
extern "js" fn is_unicode_punctuation_ffi(code : Int32) -> Bool =
  #|(code) => /[\p{P}\p{S}]/u.test(String.fromCodePoint(code))

///|
#cfg(target="js")
extern "js" fn is_whitespace_ffi(code : Int32) -> Bool =
  #|(code) => {
  #|  const char = String.fromCodePoint(code);
  #|  // Match Unicode whitespace using JS regex
  #|  return /\s/.test(char);
  #|}

///|
#cfg(target="js")
extern "js" fn is_punctuation_ffi(code : Int32) -> Bool =
  #|(code) => {
  #|  const char = String.fromCodePoint(code);
  #|  // Match Unicode punctuation categories (Pc, Pd, Pe, Pf, Pi, Po, Ps)
  #|  return /[\p{P}]/u.test(char);
  #|}

// Non-JS backend implementation using the `moonbit-community/unicode` tables.

///|
// These values are intentionally unused by the JS implementation; they keep
// the `@unicode` import live on every target.
let _unicode_is_whitespace : (Char) -> Bool = @unicode.is_white_space

///|
// `true` for the Unicode `P` (punctuation) general category group.
let _unicode_is_punctuation : (Char) -> Bool = @unicode.is_punctuation

///|
// `true` for the Unicode `P` (punctuation) or `S` (symbol) general category
// groups, with a single category lookup. `@unicode.is_punctuation` covers `P`
// only, while CommonMark counts both groups as punctuation.
let _unicode_is_unicode_punctuation : (Char) -> Bool = c => {
  let group = @unicode.general_category(c).group()
  group is P || group is S
}

///|
/// Check if a character is a Unicode whitespace
/// Uses the Unicode White_Space property
#cfg(not(target="js"))
pub fn is_whitespace(c : Char) -> Bool {
  _unicode_is_whitespace(c)
}

///|
/// Check if a character is a Unicode punctuation
/// Uses the Unicode `P` (punctuation) general category group
#cfg(not(target="js"))
pub fn is_punctuation(c : Char) -> Bool {
  _unicode_is_punctuation(c)
}

///|
/// Check if a character is a
/// [Unicode punctuation character](https://spec.commonmark.org/0.31.2/#unicode-punctuation-character),
/// i.e. in the Unicode `P` (punctuation) or `S` (symbol) general categories.
#cfg(not(target="js"))
fn is_unicode_punctuation(c : Char) -> Bool {
  _unicode_is_unicode_punctuation(c)
}
