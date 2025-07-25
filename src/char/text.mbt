///|
pub fn at_checked(s : @string.View, idx : Int) -> Result[Char, Int] {
  let min_leading_surrogate = 0xD800
  let max_leading_surrogate = 0xDBFF
  let min_trailing_surrogate = 0xDC00
  let max_trailing_surrogate = 0xDFFF
  fn is_leading_surrogate(c : Int) -> Bool {
    min_leading_surrogate <= c && c <= max_leading_surrogate
  }

  fn is_trailing_surrogate(c : Int) -> Bool {
    min_trailing_surrogate <= c && c <= max_trailing_surrogate
  }

  fn code_point_of_surrogate_pair(leading : Int, trailing : Int) -> Char {
    ((leading - 0xD800) * 0x400 + trailing - 0xDC00 + 0x10000).unsafe_to_char()
  }

  let c1 = s[idx]
  if is_leading_surrogate(c1) {
    guard idx + 1 < s.length() else { Err(c1) }
    let c2 = s[idx + 1]
    Ok(code_point_of_surrogate_pair(c1, c2))
  } else if is_trailing_surrogate(c1) {
    Err(c1)
  } else {
    Ok(c1.unsafe_to_char())
  }
}

///|
pub fn sub_includes(
  affix~ : String,
  s : String,
  first~ : Int,
  last~ : Int,
) -> Bool {
  let len_a = affix.length()
  let len_s = last - first + 1
  guard len_a <= len_s else { false }
  let max_idx_a = len_a - 1
  let max_idx_s = first + (len_s - len_a)
  for i = first, k = 0 {
    guard i <= max_idx_s else { return false }
    guard k <= max_idx_a else { return true }
    if s[i + k] == affix[k] {
      continue i, k + 1
    }
    continue i + 1, 0
  }
}

///|
pub fn prev_char(s : @string.View, first~ : Int, before~ : Int) -> Char {
  guard first < before else { ' ' }
  let k = for start = before - 1; ; start = start - 1 {
    guard first <= start else { break first }
    if s[start]
      is ('\u{0}'..='\u{7f}'
      | '\u{c2}'..='\u{df}'
      | '\u{e0}'..='\u{ef}'
      | '\u{f0}'..='\u{f4}') {
      break start
    }
  }
  s.get_char(k).unwrap()
}

///|
pub fn next_char(s : @string.View, last~ : Int, after~ : Int) -> Char {
  guard after < last else { ' ' }
  s.get_char(after + 1).unwrap()
}

///|
pub fn utf_16_clean_raw(
  pad~ : Int = 0,
  buf : Buffer,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  fn pad_it() {
    for _ in 0..<pad {
      buf.write_char(' ')
    }
  }

  fn clean(last, first, dirty) {
    let flush = fn(last, start, k) {
      if start <= last {
        buf.write_substring(s, start, k - start)
      }
    }
    flush(last, first, dirty)
    for start = dirty, k = dirty {
      if k > last {
        flush(last, start, k)
        break buf.to_string()
      }
      if s[k] == '\u{0}' {
        let next = k + 1
        flush(last, start, k)
        buf.write_char(rep)
        continue next, next
      }
      if s[k].to_char() is Some(c) && c.is_ascii() {
        continue start, k + 1
      }
      match at_checked(s, k) {
        Ok(d) => {
          let next = k + length_utf16(d.to_int())
          continue start, next
        }
        Err(d) => {
          let next = k + length_utf16(d)
          flush(last, start, k)
          buf.write_char(rep)
          continue next, next
        }
      }
    }
  }

  fn check(last, first, k) {
    for k = k {
      break if k > last {
        s.substring(start=first, end=last + 1)
      } else if s[k] == '\u{0}' {
        buf.reset()
        clean(last, first, k)
      } else if s[k].to_char() is Some(c) && c.is_ascii() {
        continue k + 1
      } else {
        match at_checked(s, k) {
          Ok(d) => {
            let next = k + length_utf16(d.to_int())
            continue next
          }
          Err(_d) => {
            buf.reset()
            clean(last, first, k)
          }
        }
      }
    }
  }

  if first > last {
    if pad == 0 {
      return ""
    }
    buf.reset()
    pad_it()
    return buf.to_string()
  }
  let max = s.length() - 1
  let last = @cmp.minimum(last, max)
  let first = @cmp.maximum(first, 0)
  if pad == 0 {
    return check(last, first, first)
  }
  buf.reset()
  pad_it()
  clean(last, first, first)
}

///|
pub fn utf_16_clean_unesc_unref(
  buf : Buffer,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  _utf_16_clean_unesc_unref(do_unesc=true, buf, s, first~, last~)
}

///|
pub fn utf_16_clean_unref(
  buf : Buffer,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  _utf_16_clean_unesc_unref(do_unesc=false, buf, s, first~, last~)
}

///|
fn flush(buf : Buffer, s : String, last : Int, start : Int, k : Int) -> Unit {
  if start <= last {
    buf.write_substring(s, start, k - start)
  }
}

///|
fn _utf_16_clean_unesc_unref(
  do_unesc~ : Bool,
  buf : Buffer,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  let flush = fn(last, start, k) { flush(buf, s, last, start, k) }

  /// https://spec.commonmark.org/current/#hexadecimal-numeric-character-references
  letrec try_entity_hex = fn(last, start, num_start, k, u) {
    for k = k, u = u {
      if k > last || k > num_start + 6 {
        return resolve(last, start, k)
      }
      match s[k] {
        ';' => {
          let next = k + 1
          if k == num_start {
            return resolve(last, start, next)
          }
          let u = match Int::to_char(u) {
            Some('\u{0}') | None => rep
            Some(u) => u
          }
          flush(last, start, num_start - 3) // Chop off `&#x` or `&#X`
          buf.write_char(u)
          return resolve(last, next, next)
        }
        c => {
          let c = c.unsafe_to_char()
          guard c.is_ascii_hexdigit() else { return resolve(last, start, k) }
          let u = u * 16 + ascii_hexdigit_to_int(c)
          continue k + 1, u
        }
      }
    }
  }
  and try_entity_dec = fn(last, start, num_start, k, u) {
    for k = k, u = u {
      if k > last || k > num_start + 7 {
        return resolve(last, start, k)
      }
      match s[k] {
        ';' => {
          let next = k + 1
          if k == num_start {
            return resolve(last, start, next)
          }
          let u = match Int::to_char(u) {
            Some('\u{0}') | None => rep
            Some(u) => u
          }
          flush(last, start, num_start - 2) // Chop off `&#`
          buf.write_char(u)
          return resolve(last, next, next)
        }
        c => {
          let c = c.unsafe_to_char()
          guard c.is_ascii_digit() else { return resolve(last, start, k) }
          let u = u * 10 + ascii_digit_to_int(c)
          continue k + 1, u
        }
      }
    }
  }
  /// https://spec.commonmark.org/current/#entity-and-numeric-character-references 
  and try_entity_named = fn(last, start, name_start, k) {
    for k = k {
      if k > last {
        return resolve(last, start, k)
      }
      match s[k] {
        ';' => {
          let name = s.substring(start=name_start, end=k)
          match html_named_entity(name) {
            None => return resolve(last, start, k + 1)
            Some(e) => {
              let next = k + 1
              flush(last, start, name_start - 1) // Chop off `&`
              buf.write_string(e)
              return resolve(last, next, next)
            }
          }
        }
        c => {
          let c = c.unsafe_to_char()
          guard is_ascii_alphanum(c) else { return resolve(last, start, k) }
          continue k + 1
        }
      }
    }
  }
  and resolve = fn(last, start, k) {
    for start = start, k = k {
      if k > last {
        flush(last, start, k)
        return buf.to_string()
      }
      let next = k + 1
      match (s[k], do_unesc) {
        ('\u{0}', _) => {
          flush(last, start, k)
          buf.write_char(rep)
          continue next, next
        }
        ('\\', true) => {
          if next > last {
            continue start, next
          }
          let nc = s[next].unsafe_to_char()
          if not(is_ascii_punctuation(nc)) {
            continue start, next
          }
          let next1 = next + 1
          flush(last, start, k)
          buf.write_char(nc)
          continue next1, next1
        }
        ('&', _) => {
          if k + 2 > last {
            continue start, next
          }
          match s[next] {
            '#' => {
              let next = next + 1
              match s[next] {
                'x' | 'X' => {
                  let next = next + 1
                  return try_entity_hex(last, start, next, next, 0)
                }
                c => {
                  if c.to_char() is Some(c) && c.is_ascii_digit() {
                    return try_entity_dec(last, start, next, next, 0)
                  }
                  continue start, next
                }
              }
            }
            c => {
              if c.to_char() is Some(c) && c.is_ascii_alphabetic() {
                return try_entity_named(last, start, next, next)
              }
              continue start, next
            }
          }
        }
        (b, _) => {
          if b.to_char() is Some(c) && c.is_ascii() {
            continue start, next
          }
          match at_checked(s, k) {
            Ok(d) => {
              let next = k + length_utf16(d.to_int())
              continue start, next
            }
            Err(d) => {
              let next = k + length_utf16(d)
              flush(last, start, k)
              buf.write_char(rep)
              continue next, next
            }
          }
        }
      }
    }
  }

  guard first <= last else { return "" }
  let max = s.length() - 1
  let last = @cmp.minimum(last, max)
  let first = @cmp.maximum(first, 0)
  for k = first {
    guard k <= last else { break s.substring(start=first, end=last + 1) }
    match (s[k], do_unesc) {
      ('\\', true) | ('&', _) | ('\u{0}', _) => {
        buf.reset()
        break resolve(last, first, k)
      }
      (b, _) => {
        if b.to_char() is Some(c) && c.is_ascii() {
          continue k + 1
        }
        match at_checked(s, k) {
          Ok(d) => {
            let next = k + length_utf16(d.to_int())
            continue next
          }
          Err(_d) => {
            buf.reset()
            break resolve(last, first, k)
          }
        }
      }
    }
  }
}
