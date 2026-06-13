///|
fn code_point_of_surrogate_pair(leading : UInt16, trailing : UInt16) -> Char {
  ((leading.to_int() - 0xD800) * 0x400 + trailing.to_int() - 0xDC00 + 0x10000).unsafe_to_char()
}

///|
pub fn at_checked(s : StringView, idx : Int) -> Result[Char, Int] {
  guard 0 <= idx && idx < s.length() else { Err(0) }
  let c1 = s[idx]
  if c1.is_leading_surrogate() {
    guard idx + 1 < s.length() && s[idx + 1].is_trailing_surrogate() else {
      Err(c1.to_int())
    }
    Ok(code_point_of_surrogate_pair(c1, s[idx + 1]))
  } else if c1.is_trailing_surrogate() {
    Err(c1.to_int())
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
pub fn prev_char(s : StringView, first~ : Int, before~ : Int) -> Char {
  guard 0 <= first && first < before && before <= s.length() else { ' ' }
  let k = before - 1
  let u = s[k]
  if u.is_trailing_surrogate() {
    if k > first && s[k - 1].is_leading_surrogate() {
      code_point_of_surrogate_pair(s[k - 1], u)
    } else {
      rep
    }
  } else {
    match u.to_char() {
      Some(c) => c
      // Lone leading surrogate.
      None => rep
    }
  }
}

///|
pub fn next_char(s : StringView, last~ : Int, after~ : Int) -> Char {
  guard after < last && after + 1 < s.length() else { ' ' }
  match at_checked(s, after + 1) {
    Ok(c) => c
    Err(_) => rep
  }
}

///|
pub fn utf_16_clean_raw(
  pad? : Int = 0,
  buf : StringBuilder,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  fn pad_it() {
    for _ in 0..<pad {
      buf.write_char(' ')
    }
  }

  // Writes [first;last] to [buf], replacing U+0000, unpaired surrogates
  // and characters whose surrogate pair is cut by the span with U+FFFD.
  // Never creates string views: a view boundary that lands on an
  // unpaired surrogate aborts.
  fn clean(last, first) {
    for k = first {
      guard k <= last else { break buf.to_string() }
      let u = s[k]
      if u == '\u{0}' {
        buf.write_char(rep)
        continue k + 1
      }
      match u.to_char() {
        Some(c) => {
          buf.write_char(c)
          continue k + 1
        }
        None =>
          match at_checked(s, k) {
            Ok(d) if k + 1 <= last => {
              buf.write_char(d)
              continue k + length_utf16(d.to_int())
            }
            // Unpaired surrogate, or a pair whose trailing half
            // lies beyond [last].
            _ => {
              buf.write_char(rep)
              continue k + 1
            }
          }
      }
    }
  }

  // Whether [first;last] can be returned as a plain substring copy.
  fn is_clean(last, first) {
    for k = first {
      guard k <= last else {
        // The view boundary at last + 1 must not land on the trailing
        // half of a surrogate pair.
        break last + 1 >= s.length() || !s[last + 1].is_trailing_surrogate()
      }
      let u = s[k]
      guard u != '\u{0}' else { break false }
      match u.to_char() {
        Some(_) => continue k + 1
        None =>
          match at_checked(s, k) {
            Ok(d) if k + 1 <= last => continue k + length_utf16(d.to_int())
            _ => break false
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
  if pad == 0 && is_clean(last, first) {
    return s[first:last + 1].to_owned()
  }
  buf.reset()
  pad_it()
  clean(last, first)
}

///|
pub fn utf_16_clean_unesc_unref(
  buf : StringBuilder,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  _utf_16_clean_unesc_unref(do_unesc=true, buf, s, first~, last~)
}

///|
pub fn utf_16_clean_unref(
  buf : StringBuilder,
  s : String,
  first~ : Int,
  last~ : Int,
) -> String {
  _utf_16_clean_unesc_unref(do_unesc=false, buf, s, first~, last~)
}

///|
fn flush(
  buf : StringBuilder,
  s : String,
  last : Int,
  start : Int,
  k : Int,
) -> Unit {
  if start <= last {
    for j = start {
      guard j < k else { break }
      match at_checked(s, j) {
        Ok(c) => {
          buf.write_char(c)
          continue j + length_utf16(c.to_int())
        }
        Err(_) => {
          buf.write_char(rep)
          continue j + 1
        }
      }
    }
  }
}

///|
fn _utf_16_clean_unesc_unref(
  do_unesc~ : Bool,
  buf : StringBuilder,
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
          let name = s[name_start:k].to_owned()
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
          if !is_ascii_punctuation(nc) {
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
            Ok(d) if k + length_utf16(d.to_int()) - 1 <= last => {
              let next = k + length_utf16(d.to_int())
              continue start, next
            }
            // Unpaired surrogate, or a valid pair whose trailing half
            // lies beyond [last]: emit U+FFFD and keep the span
            // boundary, matching `utf_16_clean_raw`.
            _ => {
              flush(last, start, k)
              buf.write_char(rep)
              continue k + 1, k + 1
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
    guard k <= last else {
      // The view boundary at last + 1 must not land on the trailing
      // half of a surrogate pair.
      if last + 1 < s.length() && s[last + 1].is_trailing_surrogate() {
        buf.reset()
        break resolve(last, first, last + 1)
      }
      break s[first:last + 1].to_owned()
    }
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
          Ok(d) if k + length_utf16(d.to_int()) - 1 <= last => {
            let next = k + length_utf16(d.to_int())
            continue next
          }
          // Unpaired surrogate, or a pair cut by the end of the span.
          _ => {
            buf.reset()
            break resolve(last, first, k)
          }
        }
      }
    }
  }
}
