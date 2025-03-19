///|
pub fn at(s : String, idx : Int) -> Char {
  Char::from_int(code_point_at(s, idx))
}

///|
pub fn at_checked(s : String, idx : Int) -> Result[Char, Char] {
  let cp = code_point_at(s, idx)
  match from_int_checked(cp) {
    Some(c) => Ok(c)
    None => Err(Char::from_int(cp))
  }
}

///|
pub fn sub_includes(
  affix~ : String,
  s : String,
  first~ : Int,
  last~ : Int
) -> Bool {
  let len_a = affix.length()
  let len_s = last - first + 1
  if len_a > len_s {
    return false
  }
  let max_idx_a = len_a - 1
  let max_idx_s = first + (len_s - len_a)
  loop first, 0 {
    i, k => {
      if i > max_idx_s {
        break false
      }
      if k > max_idx_a {
        break true
      }
      if k > 0 {
        if affix[k] == s[i + k] {
          continue i, k + 1
        } else {
          continue i + 1, 0
        }
      }
      if affix[0] == s[i] {
        continue i, 1
      } else {
        continue i + 1, 0
      }
    }
  }
}

// https://github.com/mathiasbynens/String.prototype.codePointAt/blob/c3b623184014a50de6cf3e322f0cf598c3fd4894/implementation.js#L20-L33
///|
fn code_point_at(s : String, idx : Int) -> Int {
  let fst = s[idx].to_int()
  if is_high_surrogate(fst) && idx < s.length() - 1 { // there is a next code unit
    let snd = s[idx + 1].to_int()
    if is_low_surrogate(snd) {
      // https://mathiasbynens.be/notes/javascript-encoding#surrogate-formulae
      return (fst - 0xD800) * 0x400 + snd - 0xDC00 + 0x10000
    }
  }
  fst
}

///|
pub fn prev_char(s : String, first~ : Int, before~ : Int) -> Char {
  if before <= first {
    return ' '
  }
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
  at(s, k)
}

///|
pub fn next_char(s : String, last~ : Int, after~ : Int) -> Char {
  if after >= last {
    return ' '
  }
  at(s, after + 1)
}

///|
pub fn utf_16_clean_raw(
  pad~ : Int = 0,
  buf : Buffer,
  s : String,
  first~ : Int,
  last~ : Int
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
    loop last, dirty, dirty {
      last, start, k => {
        if k > last {
          flush(last, start, k)
          break buf.to_string()
        }
        if s[k] == '\u{0}' {
          let next = k + 1
          flush(last, start, k)
          buf.write_char(rep)
          continue last, next, next
        }
        if s[k].is_ascii() {
          continue last, start, k + 1
        }
        match at_checked(s, k) {
          Ok(d) => {
            let next = k + length_utf16(d)
            continue last, start, next
          }
          Err(d) => {
            let next = k + length_utf16(d)
            flush(last, start, k)
            buf.write_char(rep)
            continue last, next, next
          }
        }
      }
    }
  }

  fn check(last, first, k) {
    loop last, first, k {
      last, first, k =>
        if k > last {
          s.substring(start=first, end=last + 1)
        } else if s[k] == '\u{0}' {
          buf.reset()
          clean(last, first, k)
        } else if s[k].is_ascii() {
          continue last, first, k + 1
        } else {
          match at_checked(s, k) {
            Ok(d) => {
              let next = k + length_utf16(d)
              continue last, first, next
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
  let last = @math.minimum(last, max)
  let first = @math.maximum(first, 0)
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
  last~ : Int
) -> String {
  _utf_16_clean_unesc_unref(do_unesc=true, buf, s, first~, last~)
}

///|
pub fn utf_16_clean_unref(
  buf : Buffer,
  s : String,
  first~ : Int,
  last~ : Int
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
  last~ : Int
) -> String {
  let flush = fn(last, start, k) { flush(buf, s, last, start, k) }

  // https://spec.commonmark.org/current/#hexadecimal-numeric-character-references
  fn try_entity_hex(last, start, num_start, k, u) {
    loop last, start, num_start, k, u {
      last, start, num_start, k, u => {
        if k > last || k > num_start + 6 {
          return resolve(last, start, k)
        }
        match s[k] {
          ';' => {
            let next = k + 1
            if k == num_start {
              return resolve(last, start, next)
            }
            let u = match from_int_checked(u) {
              Some('\u{0}') | None => rep
              Some(u) => u
            }
            flush(last, start, num_start - 3) // Chop off `&#x` or `&#X`
            buf.write_char(u)
            resolve(last, next, next)
          }
          c => {
            guard c.is_ascii_hexdigit() else { return resolve(last, start, k) }
            let u = u * 16 + ascii_hexdigit_to_int(c)
            continue last, start, num_start, k + 1, u
          }
        }
      }
    }
  }

  fn try_entity_dec(last, start, num_start, k, u) {
    loop last, start, num_start, k, u {
      last, start, num_start, k, u => {
        if k > last || k > num_start + 7 {
          return resolve(last, start, k)
        }
        match s[k] {
          ';' => {
            let next = k + 1
            if k == num_start {
              return resolve(last, start, next)
            }
            let u = match from_int_checked(u) {
              Some('\u{0}') | None => rep
              Some(u) => u
            }
            flush(last, start, num_start - 2) // Chop off `&#`
            buf.write_char(u)
            resolve(last, next, next)
          }
          c => {
            guard c.is_ascii_digit() else { return resolve(last, start, k) }
            let u = u * 10 + ascii_digit_to_int(c)
            continue last, start, num_start, k + 1, u
          }
        }
      }
    }
  }

  // https://spec.commonmark.org/current/#entity-and-numeric-character-references 
  fn try_entity_named(last, start, name_start, k) {
    loop last, start, name_start, k {
      last, start, name_start, k => {
        if k > last {
          return resolve(last, start, k)
        }
        match s[k] {
          ';' => {
            let name = s.substring(start=name_start, end=k)
            match html_named_entity(name) {
              None => resolve(last, start, k + 1)
              Some(e) => {
                let next = k + 1
                flush(last, start, name_start - 1) // Chop off `&`
                buf.write_string(e)
                resolve(last, next, next)
              }
            }
          }
          c => {
            guard is_ascii_alphanum(c) else { return resolve(last, start, k) }
            continue last, start, name_start, k + 1
          }
        }
      }
    }
  }

  fn resolve(last, start, k) {
    loop last, start, k {
      last, start, k => {
        if k > last {
          flush(last, start, k)
          return buf.to_string()
        }
        let next = k + 1
        match (s[k], do_unesc) {
          ('\u{0}', _) => {
            flush(last, start, k)
            buf.write_char(rep)
            continue last, next, next
          }
          ('\\', true) => {
            if next > last {
              continue last, start, next
            }
            let nc = s[next]
            if not(is_ascii_punctuation(nc)) {
              continue last, start, next
            }
            let next1 = next + 1
            flush(last, start, k)
            buf.write_char(nc)
            continue last, next1, next1
          }
          ('&', _) => {
            if k + 2 > last {
              continue last, start, next
            }
            match s[next] {
              '#' => {
                let next = next + 1
                match s[next] {
                  'x' | 'X' => {
                    let next = next + 1
                    try_entity_hex(last, start, next, next, 0)
                  }
                  c => {
                    if c.is_ascii_digit() {
                      return try_entity_dec(last, start, next, next, 0)
                    }
                    continue last, start, next
                  }
                }
              }
              c => {
                if c.is_ascii_alphabetic() {
                  return try_entity_named(last, start, next, next)
                }
                continue last, start, next
              }
            }
          }
          (b, _) => {
            if b.is_ascii() {
              continue last, start, next
            }
            match at_checked(s, k) {
              Ok(d) => {
                let next = k + length_utf16(d)
                continue last, start, next
              }
              Err(d) => {
                let next = k + length_utf16(d)
                flush(last, start, k)
                buf.write_char(rep)
                continue last, next, next
              }
            }
          }
        }
      }
    }
  }

  if first > last {
    return ""
  }
  let max = s.length() - 1
  let last = @math.minimum(last, max)
  let first = @math.maximum(first, 0)
  loop last, first, first {
    last, start, k => {
      if k > last {
        break s.substring(start=first, end=first + last - start + 1)
      }
      match (s[k], do_unesc) {
        ('\\', true) | ('&', _) | ('\u{0}', _) => {
          buf.reset()
          resolve(last, start, k)
        }
        (b, _) => {
          if b.is_ascii() {
            continue last, start, k + 1
          }
          match at_checked(s, k) {
            Ok(d) => {
              let next = k + length_utf16(d)
              continue last, start, next
            }
            Err(_d) => {
              buf.reset()
              resolve(last, start, k)
            }
          }
        }
      }
    }
  }
}
