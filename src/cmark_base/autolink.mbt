///| `autolink_email(s, last, start)` matches an email autolink starting at
/// `start` in the range `[start;last]` (assumed on the same line).
pub fn autolink_email(s : String, last~ : Int = -1, start~ : Int = 0) -> Last? {
  let last = if last < 0 { s.length() + last } else { last }
  fn char_is_alphanum_or_hyp(c) {
    @char.is_ascii_alphanum(c) || c == '-'
  }

  fn label_seq(last : Int, k : Int) -> Int? {
    guard k <= last &&
      s[k].to_char() is Some(c) &&
      @char.is_ascii_alphanum(c) else {
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
  for k in (start + 1)..=last {
    let sk = s[k].unsafe_to_char()
    if char_is_atext_plus_dot(sk) {
      continue
    }
    if sk == '@' &&
      s[k - 1].to_char() is Some(c) &&
      char_is_atext_plus_dot(c) {
      break label_seq(last, k + 1)
    }
    break None
  } else {
    None
  }
}

///| `autolink_uri(s, last, start)` matches an URI autolink starting at
/// `start` in the range `[start;last]` (assumed on the same line).
pub fn autolink_uri(s : String, last~ : Int = -1, start~ : Int = 0) -> Last? {
  let last = if last < 0 { s.length() + last } else { last }
  let char_is_scheme = fn(c) {
    @char.is_ascii_alphanum(c) || c is ('+' | '-' | '.')
  }
  let char_is_uri = fn(c : Char) {
    not(c is ('\u{0}'..='\u{1f}' | '\u{7f}' | '<' | '>' | ' '))
  }
  let rest = fn(s : String, last, k) {
    for k in k..=last {
      let sk = s[k].unsafe_to_char()
      guard not(char_is_uri(sk)) else { continue }
      break if sk == '>' { Some(k) } else { None }
    } else {
      None
    }
  }
  let next = start + 1
  guard next <= last &&
    s[start] == '<' &&
    s[next].unsafe_to_char().is_ascii_alphabetic() else {
    return None
  }
  for c = 1, k = next + 1 {
    guard k <= last else { break None }
    let sk = s[k].unsafe_to_char()
    if char_is_scheme(sk) && c <= 32 {
      continue c + 1, k + 1
    }
    if sk == ':' && 2 <= c && c <= 32 {
      break rest(s, last, k + 1)
    }
    break None
  }
}
