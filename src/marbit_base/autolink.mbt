/// `autolink_email(s, last, start)` matches an email autolink starting at
/// `start` in the range `[start;last]` (assumed on the same line).
pub fn autolink_email(
  s : String,
  ~last : Int = s.length() - 1,
  ~start : Int = 0
) -> Last? {
  fn label_seq(s : String, last : Int, k : Int) -> Int? {
    fn char_is_alphanum_or_hyp(c) {
      @char.is_ascii_alphanum(c) || c == '-'
    }

    if k > last || not(@char.is_ascii_alphanum(s[k])) {
      return None
    }
    loop s, last, 1, k + 1 {
      s, last, c, k => {
        if k > last {
          break None
        }
        if char_is_alphanum_or_hyp(s[k]) && c <= 63 {
          continue s, last, c + 1, k + 1
        }
        if c > 63 || @char.is_ascii_alphanum(s[k - 1]).not() {
          break None
        }
        match s[k] {
          '>' => Some(k)
          '.' => label_seq(s, last, k + 1)
          _ => None
        }
      }
    }
  }

  if start > last || s[start] != '<' {
    return None
  }
  loop s, last, start + 1 {
    s, last, k => {
      if k > last {
        break None
      }
      if char_is_atext_plus_dot(s[k]) {
        continue s, last, k + 1
      }
      if s[k] == '@' && char_is_atext_plus_dot(s[k - 1]) {
        break label_seq(s, last, k + 1)
      }
      break None
    }
  }
}

/// `autolink_uri(s, last, start)` matches an URI autolink starting at
/// `start` in the range `[start;last]` (assumed on the same line).
pub fn autolink_uri(
  s : String,
  ~last : Int = s.length() - 1,
  ~start : Int = 0
) -> Last? {
  let char_is_scheme = fn(c) {
    @char.is_ascii_alphanum(c) || "+-.".contains_char(c)
  }
  let char_is_uri = fn(c : Char) {
    not(('\x00' <= c && c <= '\x1f') || "\x7f <>".contains_char(c))
  }
  let rest = fn(s : String, last, k) {
    loop s, last, k {
      s, last, k => {
        if k > last {
          break None
        }
        if char_is_uri(s[k]) {
          continue s, last, k + 1
        }
        if s[k] == '>' {
          break Some(k)
        }
        None
      }
    }
  }
  let next = start + 1
  if next > last || s[start] != '<' || not(@char.is_ascii_alpha(s[next])) {
    return None
  }
  loop s, last, 1, next + 1 {
    s, last, c, k => {
      if k > last {
        break None
      }
      if char_is_scheme(s[k]) && c <= 32 {
        continue s, last, c + 1, k + 1
      }
      if s[k] == ':' && 2 <= c && c <= 32 {
        break rest(s, last, k + 1)
      }
      break None
    }
  }
}
