// Unicode character classification with platform-specific implementations
// JS backend uses FFI to avoid 2MB static data from charclass
//
// IMPLEMENTATION DIFFERENCES:
//
// 1. is_whitespace:
//    - JS backend: Uses \s regex, matches only ASCII whitespace characters
//      (space, tab, newline, carriage return, form feed, vertical tab)
//    - Non-JS backend: Uses full Unicode Whitespace property (~25 characters)
//      including U+2028 (Line Separator), U+2029 (Paragraph Separator), etc.
//
// 2. is_punctuation:
//    - JS backend: Uses \p{P} regex, depends on JS engine's Unicode version
//    - Non-JS backend: Uses charclass library with fixed Unicode version
//    - Both cover Unicode punctuation categories (Pc, Pd, Pe, Pf, Pi, Po, Ps)
//    - May differ for newly added punctuation in newer Unicode versions
/// Note: Depends on JS engine's Unicode version, may differ from charclass
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
#cfg(target="js")
extern "js" fn is_whitespace_ffi(code : Int) -> Bool =
  #|(code) => {
  #|  const char = String.fromCodePoint(code);
  #|  // Match Unicode whitespace using JS regex
  #|  return /\s/.test(char);
  #|}

///|
#cfg(target="js")
extern "js" fn is_punctuation_ffi(code : Int) -> Bool =
  #|(code) => {
  #|  const char = String.fromCodePoint(code);
  #|  // Match Unicode punctuation categories (Pc, Pd, Pe, Pf, Pi, Po, Ps)
  #|  return /[\p{P}]/u.test(char);
  #|}

// Non-JS backend implementation using charclass library

///|
/// Uses charclass library with full Unicode Whitespace property
/// Check if a character is a Unicode whitespace
#cfg(not(target="js"))
pub fn is_whitespace(c : Char) -> Bool {
  @unicode.is_whitespace(c)
}

/// Uses charclass library with fixed Unicode version

///|
/// Check if a character is a Unicode punctuation
#cfg(not(target="js"))
pub fn is_punctuation(c : Char) -> Bool {
  @unicode.is_punctuation(c)
}
