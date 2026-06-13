///|
/// `autolink_email(s, last, start)` matches an email autolink starting at
/// `start` in the range `[start;last]` (assumed on the same line).
pub fn autolink_email(s : String, last? : Int = -1, start? : Int = 0) -> Last? {
  let last = if last < 0 { s.length() + last } else { last }
  fn char_is_alphanum_or_hyp(c) {
    @char.is_ascii_alphanum(c) || c == '-'
  }

  fn label_seq(last : Int, k : Int) -> Int? {
    guard k <= last && s[k].to_char() is Some(c) && @char.is_ascii_alphanum(c) else {
      return None
    }
    for c = 1, k = k + 1 {
      guard k <= last else { break None }
      let sk = s[k].unsafe_to_char()
      if char_is_alphanum_or_hyp(sk) && c <= 63 {
        continue c + 1, k + 1
      }
      guard c <= 63 &&
        s[k - 1].to_char() is Some(c) &&
        @char.is_ascii_alphanum(c) else {
        break None
      }
      break match sk {
        '>' => Some(k)
        '.' => label_seq(last, k + 1)
        _ => None
      }
    }
  }

  guard start <= last || s[start] == '<' else { None }
  for k in (start + 1)..<=last {
    let sk = s[k].unsafe_to_char()
    if char_is_atext_plus_dot(sk) {
      continue
    }
    if sk == '@' && s[k - 1].to_char() is Some(c) && char_is_atext_plus_dot(c) {
      break label_seq(last, k + 1)
    }
    break None
  } nobreak {
    None
  }
}

///|
/// `autolink_uri(s, last, start)` matches an URI autolink starting at
/// `start` in the range `[start;last]` (assumed on the same line).
pub fn autolink_uri(s : String, last? : Int = -1, start? : Int = 0) -> Last? {
  let last = if last < 0 { s.length() + last } else { last }
  let char_is_scheme = fn(c) {
    @char.is_ascii_alphanum(c) || c is ('+' | '-' | '.')
  }
  // Code units outside the excluded ASCII set are URI chars; surrogate
  // halves belong to non-ASCII chars, which are allowed.
  let unit_is_uri = fn(u : UInt16) {
    match u.to_char() {
      Some(c) => !(c is ('\u{0}'..='\u{1f}' | '\u{7f}' | '<' | '>' | ' '))
      None => true
    }
  }
  let rest = fn(s : String, last, k) {
    for k in k..<=last {
      let u = s[k]
      guard !unit_is_uri(u) else { continue }
      break if u == '>' { Some(k) } else { None }
    } nobreak {
      None
    }
  }
  let next = start + 1
  guard next <= last &&
    s[start] == '<' &&
    s[next].to_char() is Some(first_scheme_char) &&
    first_scheme_char.is_ascii_alphabetic() else {
    return None
  }
  for c = 1, k = next + 1 {
    guard k <= last else { break None }
    guard s[k].to_char() is Some(sk) else { break None }
    if char_is_scheme(sk) && c <= 32 {
      continue c + 1, k + 1
    }
    if sk == ':' && 2 <= c && c <= 32 {
      break rest(s, last, k + 1)
    }
    break None
  }
}
