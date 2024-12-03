///| `link_destination(s, last, start)` matches a link destination
/// starting at `start` in the range `start..=last` (assumed on
/// the same line). This is `Some((delimited, first, last))` with the
/// data in [first..=last] the destination data. `delimited` is
/// `true` if `first-1` is '<' and `last + 1` is '>'.
///
/// See: https://spec.commonmark.org/current/#link-destination
pub fn link_destination(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> (Bool, First, Last)? {
  if start > last {
    return None
  }
  if s[start] == '<' {
    // delimited, i.e. start has '<'
    // https://spec.commonmark.org/current/#link-destination 1st
    loop s, start, last, '\x00', start + 1 {
      s, start, last, prev, k => {
        if k > last {
          break None
        }
        let c = s[k]
        match (c, prev) {
          ('\n' | '\r', _) => break None
          ('\\', '\\') => continue s, start, last, '\x00', k + 1
          ('<', '\\') => ()
          ('<', _) => break None
          ('>', '\\') => ()
          ('>', _) => break Some((true, start + 1, k - 1))
          (_, _) => ()
        }
        continue s, start, last, c, k + 1
      }
    }
  } else {
    // not_delimited
    // https://spec.commonmark.org/current/#link-destination 2nd
    loop s, start, last, '\x00', 0, start {
      s, start, last, prev, bal, k => {
        if k > last {
          break if bal == 0 { Some((false, start, k - 1)) } else { None }
        }
        let c = s[k]
        match (c, prev) {
          ('\\', '\\') => continue s, start, last, '\x00', bal, k + 1
          ('(', '\\') => ()
          ('(', _) => continue s, start, last, c, bal + 1, k + 1
          (')', '\\') => ()
          (')', _) => {
            let bal = bal - 1
            if bal < 0 {
              break Some((false, start, k - 1)) // hit inline link closing ')'
            }
            continue s, start, last, c, bal, k + 1
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
        continue s, start, last, c, bal, k + 1
      }
    }
  }
}

///| `link_title(next_line, s, lines, line, last)` is a link title on line `line` starting at `start`. 
/// Returns `Some((lines, last_line, spans, last))` with `lines` the lines after consuming the title,
/// `last_line` the line where it stops, `spans` the byte ranges of `s` that make up the title in reverse
/// order, `last` is on the closing delimiter and guaranteed to be on `last_line`. 
///
/// See: https://spec.commonmark.org/current/#link-title 
pub fn link_title[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], Last)? {
  if start > line.last {
    return None
  }
  match s[start] {
    '"' | '\'' as char =>
      accept_upto(char~, next_line~, s, lines, line~, Nil, after=start)
    '(' => {
      let start = start + 1
      loop next_line, s, lines, line, false, start, List::Nil, start {
        next_line, s, lines, line, prev_bslash, start, acc, k =>
          if k > line.last {
            guard let Some((lines, newline)) = next_line(lines) else {
              _ => break None
            }
            if newline.first > newline.last {
              break None
            }
            let acc = push_span(line~, start, line.last, acc)
            let start = first_non_blank_in_span(s, newline)
            let prev_bslash = false
            continue next_line, s, lines, newline, prev_bslash, start, acc, start
          } else {
            if prev_bslash.not() {
              if s[k] == '(' {
                break None
              }
              if s[k] == ')' {
                break Some(
                  (lines, line, push_span(line~, start, k - 1, acc), k),
                )
              }
            }
            let prev_bslash = s[k] == '\\' && prev_bslash.not()
            continue next_line, s, lines, line, prev_bslash, start, acc, k + 1
          }
      }
    }
    _ => None
  }
}

///| Matches a link label on `line` starting at `start`.
/// The byte ranges have the label's content, the string is the normalized label.
/// `buf` is used as scratch space.
///
/// See: https://spec.commonmark.org/current/#link-label
pub fn link_label[A](
  buf : Buffer,
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], Last, String)? {
  if start > line.last || s[start] != '[' {
    return None
  }
  let start = start + 1
  buf.reset()
  loop buf, next_line, s, lines, line, '\x00', start, List::Nil, 0, start {
    b, next_line, s, lines, line, prev, start, acc, count, k => {
      if k > line.last {
        guard let Some((lines, newline)) = next_line(lines) else {
          _ => break None
        }
        if newline.first == newline.last {
          break None
        }
        let acc = push_span(line~, start, line.last, acc)
        let start = first_non_blank_in_span(s, newline)
        if b.is_empty().not() {
          b.write_char(' ')
        }
        let prev = '\x00'
        continue b, next_line, s, lines, newline, prev, start, acc, count, start
      }
      if count > 999 {
        break None
      }
      match (s[k], prev) {
        ('\\', '\\') => {
          b.write_char('\\')
          let prev = '\x00'
          continue b,
            next_line,
            s,
            lines,
            line,
            prev,
            start,
            acc,
            count + 1,
            k + 1
        }
        (']', '\\') => ()
        (']', _) => {
          let key = b.to_unchecked_string()
          if key.iter().all(@char.is_ascii_whitespace) {
            break None
          }
          let acc = push_span(line~, start, k - 1, acc)
          break Some((lines, line, acc, k, key))
        }
        ('[', '\\') => ()
        ('[', _) => break None
        (' ' | '\t' as prev, _) =>
          continue b,
            next_line,
            s,
            lines,
            line,
            prev,
            start,
            acc,
            count + 1,
            k + 1
        _ => ()
      }
      // Collapse non initial whitespace
      if @char.is_ascii_blank(prev) && b.is_empty().not() {
        b.write_char(' ')
      }
      let mut u = @char.at(s, k)
      if u == '\x00' {
        u = @char.rep
      }
      let k1 = k + @char.length_utf8(u)
      // match Cmarkit_data.unicode_case_fold u with
      // | None -> Buffer.add_utf_8_uchar b u
      // | Some fold -> Buffer.add_string b fold
      b.write_char(@char.to_ascii_lower(u))
      let prev = s[k]
      continue b, next_line, s, lines, line, prev, start, acc, count + 1, k1
    }
  }
}
