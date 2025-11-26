///|
/// `link_destination(s, last, start)` matches a link destination
/// starting at `start` in the range `start..=last` (assumed on
/// the same line). This is `Some((delimited, first, last))` with the
/// data in [first..=last] the destination data. `delimited` is
/// `true` if `first-1` is '<' and `last + 1` is '>'.
///
/// See: https://spec.commonmark.org/current/#link-destination
pub fn link_destination(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> (Bool, First, Last)? {
  if start > last {
    return None
  }
  if s[start] == '<'.to_int() {
    // delimited, i.e. start has '<'
    // https://spec.commonmark.org/current/#link-destination 1st
    for prev = '\u{0}', k = start + 1 {
      if k > last {
        break None
      }
      let c = Int::unsafe_to_char(s[k])
      match (c, prev) {
        ('\n' | '\r', _) => break None
        ('\\', '\\') => continue '\u{0}', k + 1
        ('<', '\\') => ()
        ('<', _) => break None
        ('>', '\\') => ()
        ('>', _) => break Some((true, start + 1, k - 1))
        (_, _) => ()
      }
      continue c, k + 1
    }
  } else {
    // not_delimited
    // https://spec.commonmark.org/current/#link-destination 2nd
    for prev = '\u{0}', bal = 0, k = start {
      if k > last {
        break if bal == 0 { Some((false, start, k - 1)) } else { None }
      }
      let c = Int::unsafe_to_char(s[k])
      match (c, prev) {
        ('\\', '\\') => continue '\u{0}', bal, k + 1
        ('(', '\\') => ()
        ('(', _) => continue c, bal + 1, k + 1
        (')', '\\') => ()
        (')', _) => {
          let bal = bal - 1
          if bal < 0 {
            break Some((false, start, k - 1)) // hit inline link closing ')'
          }
          continue c, bal, k + 1
        }
        (c, _) =>
          if c == ' ' || @char.is_ascii_control(c) {
            break if k != start && bal == 0 {
              Some((false, start, k - 1))
            } else {
              None
            }
          }
      }
      continue c, bal, k + 1
    }
  }
}

///|
/// `link_title(next_line, s, lines, line, last)` is a link title on line `line` starting at `start`. 
/// Returns `Some((lines, last_line, spans, last))` with `lines` the lines after consuming the title,
/// `last_line` the line where it stops, `spans` the byte ranges of `s` that make up the title in reverse
/// order, `last` is on the closing delimiter and guaranteed to be on `last_line`. 
///
/// See: https://spec.commonmark.org/current/#link-title 
pub fn[A] link_title(
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], Last)? {
  if start > line.last {
    return None
  }
  match s[start].unsafe_to_char() {
    '"' | '\'' as char => {
      let spans = []
      accept_upto(char~, next_line~, s, lines, line~, spans, after=start).map(span_last => (
        span_last.0,
        spans,
        span_last.1,
      ))
    }
    '(' => {
      let start = start + 1
      let acc = []
      for line = line, prev_bslash = false, start = start, k = start {
        if k > line.last {
          guard next_line(lines) is Some(newline) else { break None }
          guard newline.first <= newline.last else { break None }
          push_span(line~, start, line.last, acc)
          let start = first_non_blank_in_span(s, newline)
          let prev_bslash = false
          continue newline, prev_bslash, start, start
        }
        if not(prev_bslash) {
          if s[k] == '(' {
            break None
          }
          if s[k] == ')' {
            push_span(line~, start, k - 1, acc)
            break Some((line, acc, k))
          }
        }
        let prev_bslash = s[k] == '\\' && not(prev_bslash)
        continue line, prev_bslash, start, k + 1
      }
    }
    _ => None
  }
}

///|
/// Matches a link label on `line` starting at `start`.
/// The byte ranges have the label's content, the string is the normalized label.
/// `buf` is used as scratch space.
///
/// See: https://spec.commonmark.org/current/#link-label
pub fn[A] link_label(
  buf : StringBuilder,
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], Last, String)? {
  if start > line.last || s[start] != '[' {
    return None
  }
  let start = start + 1
  buf.reset()
  let acc = []
  let b = buf
  for line = line, prev = '\u{0}', start = start, count = 0, k = start {
    if k > line.last {
      guard next_line(lines) is Some(newline) else { break None }
      if newline.first == newline.last {
        break None
      }
      push_span(line~, start, line.last, acc)
      let start = first_non_blank_in_span(s, newline)
      if not(b.is_empty()) {
        b.write_char(' ')
      }
      let prev = '\u{0}'
      continue newline, prev, start, count, start
    }
    if count > 999 {
      break None
    }
    match (s[k].unsafe_to_char(), prev) {
      ('\\', '\\') => {
        b.write_char('\\')
        let prev = '\u{0}'
        continue line, prev, start, count + 1, k + 1
      }
      (']', '\\') => ()
      (']', _) => {
        let key = b.to_string()
        if key.iter().all(@char.is_ascii_whitespace) {
          break None
        }
        push_span(line~, start, k - 1, acc)
        break Some((line, acc, k, key))
      }
      ('[', '\\') => ()
      ('[', _) => break None
      (' ' | '\t' as prev, _) => continue line, prev, start, count + 1, k + 1
      _ => ()
    }
    // Collapse non initial whitespace
    if @char.is_ascii_blank(prev) && not(b.is_empty()) {
      b.write_char(' ')
    }
    let mut u = s.get_char(k).unwrap()
    if u == '\u{0}' {
      u = @char.rep
    }
    let k1 = k + @char.length_utf8(u.to_int())
    b.write_char(@char.to_ascii_lower(u))
    let prev = s[k].unsafe_to_char()
    continue line, prev, start, count + 1, k1
  }
}
